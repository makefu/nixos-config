#!/usr/bin/env python3
"""One-shot migration of the opencrow (mautrix-go / goolm) Matrix E2EE crypto
store to the layout hermes-agent's mautrix-python PgCryptoStore expects.

Run on omo with both the opencrow and hermes-agent containers stopped, in an
environment providing python-olm + cryptography:

    cp /var/lib/hermes/.hermes/platforms/matrix/store/crypto.db{,.bak}
    nix-shell -p 'python313.withPackages (ps: [ps.cryptography ps.python-olm])' \
      --run 'migrate-opencrow-crypto.py /var/lib/hermes/.hermes/platforms/matrix/store/crypto.db'

Rewrites the database IN PLACE:

  * pickle re-key. Stored blobs are goolm pickles (HKDF-SHA256
    info="Pickle", AES-256-CBC + 8-byte truncated HMAC — goolm copied
    libolm's cipher.cpp), keyed with "opencrow-default-pickle-key". Each
    row is goolm-unpickled with the old key, loaded through the real
    python-olm objects (Account / Session / Inbound/OutboundGroupSession),
    and re-pickled with "<account_id>:<device_id>" — the key hermes derives
    at adapter.py:_pickle_key — in libolm's UNPADDED base64 form. The
    stored value is byte-for-byte what mautrix itself would write, and the
    rewrap self-checks by reloading with the new key before storing.
  * account_id: go stores the empty string, python scopes every crypto_*
    table by account_id (PK includes it).
  * crypto_account.device_id: already HTi5uohXSs; kept so
    _reset_crypto_store_if_device_changed sees stored == token device and
    does NOT wipe the store.
  * crypto_version: go wrote (18, 15) for its own schema; python raises
    UnsupportedDatabaseVersion above len(upgrades). Its v10 DDL is a subset
    of the go schema (all columns exist), so pin (10, 10) and the upgrade
    table becomes a no-op.
  * timestamps: go writes Go time.Time dumps ("...13:22:07.169367255 +0200
    CEST m=+118.197436282"); sqlite3's PARSE_DECLTYPES converter chokes on
    nanoseconds and the zone/monotonic suffix. Normalise to naive UTC
    "YYYY-MM-DD HH:MM:SS.ffffff", the form mautrix itself writes.
    (crypto_olm_message_hash.received_at is a BIGINT epoch — leave alone.)
  * forwarding_chains: go stores a JSON array in a BLOB; python joins
    per-chain JSON documents with "," in a TEXT column.
  * mx_* tables (room state / profiles / registrations): the adapter's client
    state store is in-memory, so these go-only leftovers are dropped.

Idempotent: a database already carrying the target account_id is skipped.
Rows whose pickles fail to load are dropped (worst case: that history
renders UTD), never left half-rewritten.
"""

import base64
import datetime as dt
import hashlib
import hmac
import json
import re
import sqlite3
import sys

import olm
import olm.account
import olm.group_session
import olm.session
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

# Identity the hermes adapter will use (MATRIX_USER_ID + access-token device).
ACCOUNT_ID = "@felix-ham:matrix.cybahn.de"
DEVICE_ID = "HTi5uohXSs"
OLD_PICKLE_KEY = b"opencrow-default-pickle-key"
OLD_PICKLE_KEY_STR = OLD_PICKLE_KEY.decode()
# python-olm's from_pickle/pickle take the passphrase as str; goolm's HKDF
# wants bytes. Same secret, two representations.
NEW_PICKLE_KEY = f"{ACCOUNT_ID}:{DEVICE_ID}"

BLOB_TABLES = [
    ("crypto_account", "account"),
    ("crypto_olm_session", "session"),
    ("crypto_megolm_inbound_session", "session"),
    ("crypto_megolm_outbound_session", "session"),
]
ACCOUNT_ID_TABLES = [
    "crypto_account",
    "crypto_olm_session",
    "crypto_megolm_inbound_session",
    "crypto_megolm_outbound_session",
    "crypto_olm_message_hash",
    "crypto_secrets",
]
TIMESTAMP_COLUMNS = [
    ("crypto_olm_session", "created_at"),
    ("crypto_olm_session", "last_decrypted"),
    ("crypto_olm_session", "last_encrypted"),
    ("crypto_megolm_inbound_session", "received_at"),
    ("crypto_megolm_outbound_session", "created_at"),
    ("crypto_megolm_outbound_session", "last_used"),
]


def _b64d_nopad(s: bytes) -> bytes:
    return base64.b64decode(s + b"=" * ((4 - len(s) % 4) % 4))


def _hkdf_expand(ikm: bytes, info: bytes, n: int) -> bytes:
    prk = hmac.new(b"\x00" * 32, ikm, hashlib.sha256).digest()
    out, t, i = b"", b"", 1
    while len(out) < n:
        t = hmac.new(prk, t + info + bytes([i]), hashlib.sha256).digest()
        out += t
        i += 1
    return out[:n]


def _aes_cbc(key: bytes, iv: bytes, data: bytes, decrypt: bool) -> bytes:
    maker = (
        Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
        if decrypt
        else Cipher(algorithms.AES(key), modes.CBC(iv)).encryptor()
    )
    return maker.update(data) + maker.finalize()


def goolm_unpickle(key: bytes, blob) -> bytes:
    """goolm outer: HKDF(Pickle) -> aes32+hmac32+iv16, 8-byte MAC tail."""
    if isinstance(blob, str):
        blob = blob.encode()
    if isinstance(blob, memoryview):
        blob = blob.tobytes()
    raw = _b64d_nopad(blob)
    ct, mac = raw[:-8], raw[-8:]
    km = _hkdf_expand(key, b"Pickle", 80)
    if hmac.new(km[32:64], ct, hashlib.sha256).digest()[:8] != mac:
        raise ValueError("goolm MAC mismatch")
    return _aes_cbc(km[:32], km[64:], ct[: len(ct) // 16 * 16], True)


def goolm_pickle(key: bytes, inner: bytes) -> str:
    """Inverse of goolm_unpickle; returns the stored base64 form."""
    km = _hkdf_expand(key, b"Pickle", 80)
    padded = inner[: len(inner) // 16 * 16] + b"\x00" * ((-len(inner)) % 16)
    ct = _aes_cbc(km[:32], km[64:], padded, False)
    mac = hmac.new(km[32:64], ct, hashlib.sha256).digest()[:8]
    return base64.b64encode(ct + mac).decode()


def _dec(v, default=None):
    if v is None:
        return default
    if isinstance(v, memoryview):
        v = v.tobytes()
    return v.decode() if isinstance(v, bytes) else v


def rewrap(kind: str, blob, signed_key=None) -> bytes:
    """goolm-unpickle the stored blob (old key) -> the raw libolm pickle
    body -> hand it to python-olm with the old key -> re-pickle with the
    new key.

    goolm's outer and libolm's outer are the SAME scheme (HKDF-SHA256
    info="Pickle" -> aes32+hmac32+iv16, AES-256-CBC, 8-byte truncated HMAC
    over the ciphertext — goolm copied cipher.cpp), the only difference
    being base64 padding: libolm's encoder (and python-olm's decoder) is
    unpadded, so the re-wrap handed to python-olm must have `=` stripped.

    The result is exactly what mautrix itself would store: PgCryptoStore
    passes the raw column to olm *.from_pickle(pickle, passphrase)
    (mautrix/crypto/store/asyncpg/store.py get_account / get_sessions /
    get_inbound_group_session), and olm *.pickle(key) round-trips into that
    same call. signing/sender/room metadata are attached by mautrix after
    from_pickle, not by olm.
    """
    inner = goolm_unpickle(OLD_PICKLE_KEY, blob)
    # re-encrypt with the old key in libolm's UNPADDED base64 form —
    # python-olm's decoder rejects both the padding and a raw body
    b64 = goolm_pickle(OLD_PICKLE_KEY, inner).rstrip("=").encode()
    load = {
        "account": olm.account.Account.from_pickle,
        "olm": olm.session.Session.from_pickle,
        "inbound": olm.group_session.InboundGroupSession.from_pickle,
        "outbound": olm.group_session.OutboundGroupSession.from_pickle,
    }[kind]
    obj = load(b64, OLD_PICKLE_KEY_STR)
    new = obj.pickle(NEW_PICKLE_KEY)
    new = new if isinstance(new, bytes) else str(new).encode()
    load(new, NEW_PICKLE_KEY)  # reader self-check with the exact call
    return new


GO_TIME_RE = re.compile(
    rb"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})(\.\d+)? ?([+-]\d{4})?.*$"
)


def normalize_go_timestamp(value):
    """Go time.Time dump -> naive UTC 'YYYY-MM-DD HH:MM:SS.ffffff' (what
    mautrix writes). Unparsable values are returned unchanged."""
    if value is None:
        return None
    if isinstance(value, dt.datetime):
        value = value.isoformat(sep=" ", timespec="microseconds").encode()
    if isinstance(value, str):
        value = value.encode()
    if not isinstance(value, (bytes, bytearray)):
        return value
    m = GO_TIME_RE.match(value.strip())
    if not m:
        return value.decode(errors="replace")
    base, frac, off = m.group(1), m.group(2) or b"", m.group(3)
    micro = (frac + b"000000000")[1:7] if frac else b"000000"
    naive = dt.datetime.strptime(
        base.decode() + "." + micro.decode(), "%Y-%m-%d %H:%M:%S.%f"
    )
    if off:  # shift to UTC, then drop the zone (mautrix stores naive UTC)
        sign = 1 if off[0:1] == b"+" else -1
        delta = dt.timedelta(hours=int(off[1:3]), minutes=int(off[3:5]))
        naive = naive - sign * delta
    return naive.strftime("%Y-%m-%d %H:%M:%S.%f")


def normalize_forwarding_chains(value):
    """go: JSON array in a BLOB. python: comma-joined JSON docs in TEXT."""
    if value is None:
        return ""
    if isinstance(value, memoryview):
        value = value.tobytes()
    if isinstance(value, bytes):
        value = value.decode()
    text = value.strip()
    if not text or text in ("[]", "null"):
        return ""
    try:
        chains = json.loads(text)
    except json.JSONDecodeError:
        return text  # already the python comma-joined form
    if isinstance(chains, list):
        return ",".join(
            c if isinstance(c, str) else json.dumps(c, separators=(",", ":"))
            for c in chains
        )
    return json.dumps(chains, separators=(",", ":"))


def already_migrated(db: sqlite3.Connection) -> bool:
    row = db.execute(
        "SELECT account_id FROM crypto_account WHERE account_id != ''"
    ).fetchone()
    return row is not None


def migrate(path: str) -> None:
    db = sqlite3.connect(path)
    db.text_factory = bytes  # keep blobs/strings raw; write back explicitly

    if already_migrated(db):
        print(f"{path}: account_id already set — skipping (idempotent)")
        return

    (signing_key,) = db.execute(
        "SELECT signing_key FROM crypto_device WHERE device_id = ?", (DEVICE_ID,)
    ).fetchone()
    signing_key = _dec(signing_key)

    stats = {}
    kinds = {
        "crypto_account": "account",
        "crypto_olm_session": "olm",
        "crypto_megolm_inbound_session": "inbound",
        "crypto_megolm_outbound_session": "outbound",
    }

    # 1. Re-wrap every double pickle; drop rows python-olm rejects.
    for table, column in BLOB_TABLES:
        rows = db.execute(
            f"SELECT rowid, {column}, account_id, signing_key FROM {table}"
            if table == "crypto_megolm_inbound_session"
            else f"SELECT rowid, {column}, account_id, NULL FROM {table}"
        ).fetchall()
        ok = failed = 0
        for rowid, blob, acct, row_signing in rows:
            try:
                new = rewrap(kinds[table], blob, _dec(row_signing) or signing_key)
                acct_new = ACCOUNT_ID if _dec(acct, "") == "" else _dec(acct)
                db.execute(
                    f"UPDATE {table} SET {column} = ?, account_id = ? WHERE rowid = ?",
                    (new, acct_new, rowid),
                )
                ok += 1
            except Exception as exc:  # noqa: BLE001 — report per row
                failed += 1
                print(f"  {table} rowid={rowid}: FAILED {exc!r} — dropping row")
                db.execute(f"DELETE FROM {table} WHERE rowid = ?", (rowid,))
        stats[f"{table}.{column}"] = (ok, failed)

    # 2. Remaining account_id columns.
    for table in ACCOUNT_ID_TABLES:
        try:
            cur = db.execute(
                f"UPDATE {table} SET account_id = ? WHERE account_id = ''",
                (ACCOUNT_ID,),
            )
            stats[f"{table}.account_id"] = (cur.rowcount, 0)
        except sqlite3.OperationalError as exc:
            print(f"  {table}: account_id update skipped ({exc})")

    # 3. Version pin: python's blank-to-latest DDL is a subset of the go
    # schema; (10,10) makes upgrade_table a no-op (already-at-latest).
    db.execute("UPDATE crypto_version SET version = 10, compat = 10")
    stats["crypto_version"] = (1, 0)

    # 4. Timestamp + forwarding-chain normalisation.
    for table, column in TIMESTAMP_COLUMNS:
        rows = db.execute(f"SELECT rowid, {column} FROM {table}").fetchall()
        n = 0
        for rowid, value in rows:
            norm = normalize_go_timestamp(value)
            if norm is not None and norm != value:
                db.execute(
                    f"UPDATE {table} SET {column} = ? WHERE rowid = ?",
                    (norm, rowid),
                )
                n += 1
        stats[f"{table}.{column}"] = (n, 0)

    n = 0
    for rowid, value in db.execute(
        "SELECT rowid, forwarding_chains FROM crypto_megolm_inbound_session"
    ).fetchall():
        norm = normalize_forwarding_chains(value)
        if norm != value:
            db.execute(
                "UPDATE crypto_megolm_inbound_session "
                "SET forwarding_chains = ? WHERE rowid = ?",
                (norm, rowid),
            )
            n += 1
    stats["inbound.forwarding_chains"] = (n, 0)

    # 5. Go leftovers the python adapter never reads (its client state store
    # is in-memory). crypto_secrets / crypto_olm_message_hash /
    # outbound_session_shared are kept: harmless caches, python ignores them.
    for table in (
        "mx_room_state",
        "mx_user_profile",
        "mx_registrations",
        "mx_version",
    ):
        db.execute(f"DROP TABLE IF EXISTS {table}")

    db.commit()
    db.execute("VACUUM")
    db.close()

    print(f"migrated {path}:")
    for k, (ok, failed) in stats.items():
        print(f"  {k}: {ok} rewritten, {failed} dropped")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"usage: {sys.argv[0]} <path-to-crypto.db>")
    migrate(sys.argv[1])
