# LLM agent on omo (hermes-agent)

`agent.nix` replaced the old multi-instance opencrow (omp-based) setup on
2026-11-10. One `services.hermes-agent` (NousResearch hermes,
`github:NousResearch/hermes-agent`) runs in podman container mode
(`container.enable = true`, image `ubuntu:24.04` pulled on first create,
persistent writable layer). Deploy omo with
`clan machines update omo --build-host localhost`.

## Matrix identity / E2EE

- Bot: `@felix-ham:matrix.cybahn.de`, device `HTi5uohXSs` — the access
  token's device, pinned via `environment.MATRIX_DEVICE_ID`. A password
  login would mint a new device per start and the adapter's
  `_reset_crypto_store_if_device_changed` would silently wipe the crypto
  store; never drop that env var.
- Secrets (`clan secrets`, `hermes-env` dotenv): `MATRIX_ACCESS_TOKEN`,
  `MATRIX_USER_ID`, `OPENAI_API_KEY` (vLLM bearer), `NEXTCLOUD_TOKEN`.
  Reused unchanged: `opencrow-kagi-session-token` (also blackbox uses
  `opencrow-vllm-api-key`).
- The vLLM token is wired via `settings.model.key_env = "OPENAI_API_KEY"`:
  hermes' bare `custom` provider only sends `OPENAI_API_KEY` to
  openai.com/`OPENAI_BASE_URL` hosts (credential leak gate), so a plain
  env var would silently reach `inference.p0.contact` without auth.

## Crypto store migration (opencrow -> hermes)

`migrate-opencrow-crypto.py` converts the mautrix-go (v0.26.2) crypto DB
to the mautrix-python/python-olm format. Run once, on a copy, as root:

```sh
systemctl stop hermes-agent container@opencrow container@opencrow-nostr
cp /var/lib/opencrow/crypto.db /root/crypto.db.work
python3 2configs/home/llm/migrate-opencrow-crypto.py /root/crypto.db.work
install -o hermes -g hermes -m 0660 /root/crypto.db.work \
  /var/lib/hermes/.hermes/platforms/matrix/store/crypto.db
systemctl start hermes-agent
```

What it does:

- Stored blobs are goolm pickles (HKDF-SHA256 info=`"Pickle"`,
  AES-256-CBC + truncated 8-byte HMAC — goolm copied libolm's
  `cipher.cpp`), keyed with `opencrow-default-pickle-key`. Each row is
  goolm-unpickled with the old key, re-wrapped in libolm's UNPADDED
  base64 form (python-olm's decoder rejects `=` padding and a raw body),
  loaded with real python-olm, then re-pickled with the hermes key
  `"@felix-ham:matrix.cybahn.de:HTi5uohXSs"` — byte-for-byte what mautrix
  itself would write. Rows are self-checked by reloading before storing.
- Sets `account_id` on every `crypto_*` row (go stored `''`, python
  scopes tables by it) and `crypto_account.device_id = HTi5uohXSs` so the
  device check does not wipe the store.
- `crypto_version` -> `(10,10)` (mautrix 0.21.1 PgCryptoStore schema);
  go-only tables (`mx_*`, `crypto_secrets`, ...) dropped so mautrix's
  UpgradeTable recreates what it needs.
- Idempotent: rerunning on a migrated DB is a no-op that still passes.

Verified offline before deploy: 270/270 rows (1 account, 7 olm sessions,
261 megolm inbound, 1 outbound) round-trip through python-olm with the
new key; account identity keys equal the published device keys. Gate
script: `/tmp/hmigr/gate.py` during development (mirrors mautrix
PgCryptoStore reader calls incl. `PARSE_DECLTYPES` timestamps).

Old opencrow state kept as backup on omo: `/var/lib/opencrow` untouched
plus `tar` at `/var/backups/opencrow-20261110/`; the opencrow nixos
containers are `static` (no restart) but their data was not deleted.

## Skills

Mounted read-only into `/skills` (`settings.skills.external_dirs`); each
dir needs its `SKILL.md` inside (hermes' `rglob` does not descend through
directory symlinks — mount real dirs):

- `kagi.nix` — mics-skills `kagi-search/skill` (note: repo has no
  `skills/` dir; `SKILL.md` lives in `kagi-search/skill/`). Token
  bind-mounted at `/run/secrets/kagi-session-token`; kagi config.json
  written by tmpfiles under `${stateDir}/home/.config/kagi` because the
  container's `HOME=/home/hermes` is the host `stateDir/home` mount.
  NOTE: the kagi session token is stale (kagi redirects to turnstile);
  refresh with `clan secrets set --machine omo opencrow-kagi-session-token`.
- `kleinclaw.nix` + `kleinclaw-bin.nix` — miniclaw CLI on the container
  PATH (wrapped node script), helper skill from the kleinclaw input.
- nextcloud — `openclaw-nextcloud` input mounted as `/skills/nextcloud`;
  token + `NEXTCLOUD_URL`/`NEXTCLOUD_USER` from `.env`/`environment`.

## Container PATH

Tools come from the nix store, bind-mounted `/nix/store:ro`;
`container.extraOptions` sets the full `--env PATH=...` (store bins +
Ubuntu dirs + the uv venv). There is deliberately no `PATH` key in the
rendered `.env` — hermes `load_dotenv` would clobber the container env.
