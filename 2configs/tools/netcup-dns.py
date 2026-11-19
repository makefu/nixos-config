#!/usr/bin/env python3
"""Manage netcup DNS zones through the legacy JSON session API.

The zone is authoritative on netcup; this tool always fetches the live
record set first, computes the desired set locally, and pushes exactly
that set with updateDnsRecords. netcup's updateDnsRecords only upserts
the records it is given - rows omitted from the payload are NOT
deleted - so deletions are sent explicitly as deleterecord=true rows.

Creds: NETCUP_CUSTOMER_NUMBER / NETCUP_API_KEY / NETCUP_API_PASSWORD
from the environment or an env file (-e, KEY=VALUE lines, e.g.
`sops -d sops/secrets/lego-syntax-fehler/secret > /tmp/nc.env`).

API quirks (verified against ccp.netcup.net, Nov 2026): every param
name is lowercase (customernumber, apikey, apisessionid, domainname);
the record list must be nested as {"dnsrecordset":{"dnsrecords":[...]}}.
Anything else returns statuscode 4008/4018.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.request
from typing import Any

API_URL = "https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON"

# (hostname, type, destination, priority, ttl, id|None)
Record = dict[str, Any]


class NetcupError(RuntimeError):
    pass


def load_creds(env_file: str | None) -> dict[str, str]:
    file_vars: dict[str, str] = {}
    path = env_file or os.environ.get("NETCUP_ENV_FILE")
    if path:
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                cred_key, sep, cred_value = line.strip().partition("=")
                if sep and cred_key.startswith("NETCUP_"):
                    file_vars[cred_key] = cred_value.strip()
    creds: dict[str, str] = {}
    for name in ("NETCUP_CUSTOMER_NUMBER", "NETCUP_API_KEY", "NETCUP_API_PASSWORD"):
        value: str | None = os.environ.get(name) or file_vars.get(name)
        if not value:
            raise NetcupError(f"missing credential {name} (env or -e env file)")
        creds[name] = value
    return creds


class NetcupClient:
    def __init__(self, creds: dict[str, str]) -> None:
        self.creds = creds
        self.session_id: str | None = None

    def _post(self, action: str, param: dict[str, Any]) -> dict[str, Any]:
        body = json.dumps({"action": action, "param": param}).encode()
        req = urllib.request.Request(
            API_URL,
            data=body,
            headers={"content-type": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            msg = json.load(resp)
        if msg.get("status") != "success":
            raise NetcupError(
                f"{action}: statuscode={msg.get('statuscode')} "
                f"{msg.get('shortmessage')} {msg.get('longmessage')}"
            )
        return msg.get("responsedata") or {}

    def login(self) -> None:
        data = self._post(
            "login",
            {
                "customernumber": self.creds["NETCUP_CUSTOMER_NUMBER"],
                "apikey": self.creds["NETCUP_API_KEY"],
                "apipassword": self.creds["NETCUP_API_PASSWORD"],
            },
        )
        self.session_id = data["apisessionid"]

    def logout(self) -> None:
        if self.session_id is None:
            return
        self._post(
            "logout",
            {
                "customernumber": self.creds["NETCUP_CUSTOMER_NUMBER"],
                "apikey": self.creds["NETCUP_API_KEY"],
                "apisessionid": self.session_id,
            },
        )
        self.session_id = None

    def _authed(self, action: str, param: dict[str, Any]) -> dict[str, Any]:
        assert self.session_id is not None
        return self._post(
            action,
            {
                "customernumber": self.creds["NETCUP_CUSTOMER_NUMBER"],
                "apikey": self.creds["NETCUP_API_KEY"],
                "apisessionid": self.session_id,
                **param,
            },
        )

    def info_dns_records(self, domain: str) -> list[Record]:
        data = self._authed("infoDnsRecords", {"domainname": domain})
        return [normalize_record(r) for r in data.get("dnsrecords", [])]

    def update_dns_records(self, domain: str, records: list[Record]) -> None:
        self._authed(
            "updateDnsRecords",
            {
                "domainname": domain,
                "dnsrecordset": {"dnsrecords": [wire_record(r) for r in records]},
            },
        )


def normalize_record(raw: dict[str, Any]) -> Record:
    id_ = raw.get("id")
    return {
        "hostname": str(raw.get("hostname", "")),
        "type": str(raw.get("type", "")),
        "destination": str(raw.get("destination", "")),
        "priority": str(raw.get("priority", "") or ""),
        "ttl": raw.get("ttl"),
        "id": None if id_ in (None, "", 0, "0") else int(str(id_)),
    }


def wire_record(rec: Record) -> dict[str, Any]:
    out: dict[str, Any] = {
        "hostname": rec["hostname"],
        "type": rec["type"],
        "destination": rec["destination"],
        "priority": rec["priority"] or "0",
        "ttl": rec["ttl"],
        "state": "yes",
    }
    if rec.get("deleterecord"):
        out["deleterecord"] = True
    if rec.get("id"):
        out["id"] = str(rec["id"])
    return out


def key(rec: Record) -> tuple[str, str, str]:
    return (str(rec["hostname"]), str(rec["type"]), str(rec["destination"]))


def normalize_hostname(domain: str, hostname: str) -> str:
    """Accept '@', 'rss.euer', 'rss.euer.syntax-fehler.de' -> 'rss.euer'."""
    host = hostname.strip().rstrip(".")
    suffix = "." + domain
    if host in ("", "@"):
        return "@"
    if host == domain:
        return "@"
    host = host.removesuffix(suffix)
    return host or "@"


def plan_update(
    current: list[Record], desired: list[Record]
) -> tuple[list[Record], list[Record]]:
    """Diff current vs desired zone.

    Returns (upserts, deletions): upserts = new rows (no id) plus rows
    whose ttl/priority changed (existing id preserved so netcup maps
    them); deletions = current rows absent from desired, flagged
    deleterecord=true. Unchanged rows need no payload entry.
    """
    desired_keys = {key(r) for r in desired}
    upserts: list[Record] = []
    for rec in desired:
        match = next((c for c in current if key(c) == key(rec)), None)
        if match is None:
            upserts.append({**rec, "id": None})
        elif str(match["ttl"]) != str(rec["ttl"]) or str(match["priority"]) != str(
            rec["priority"]
        ):
            upserts.append({**rec, "id": match["id"]})
    deletions = [
        dict(r, deleterecord=True) for r in current if key(r) not in desired_keys
    ]
    return upserts, deletions


def print_zone(records: list[Record]) -> None:
    for r in sorted(records, key=lambda x: (str(x["hostname"]), str(x["type"]))):
        ttl = "auto" if r["ttl"] is None else str(r["ttl"])
        print(f"{r['hostname']:<24} {r['type']:<6} ttl={ttl:<6} {r['destination']}")


def run_push(
    client: NetcupClient, domain: str, desired: list[Record], dry_run: bool
) -> int:
    current = client.info_dns_records(domain)
    upserts, deletions = plan_update(current, desired)
    print(
        f"zone {domain}: {len(current)} current; "
        f"{len(upserts)} upsert; {len(deletions)} delete"
    )
    for r in upserts:
        print(f"  + {r['hostname']} {r['type']} {r['destination']}")
    for r in deletions:
        print(f"  - {r['hostname']} {r['type']} {r['destination']}")
    if dry_run:
        print("dry-run: nothing sent")
        return 0
    if not upserts and not deletions:
        print("zone already matches; nothing sent")
        return 0
    # single netcup call: upserts plus explicit deletion rows
    client.update_dns_records(domain, upserts + deletions)
    print("pushed.")
    print_zone(client.info_dns_records(domain))
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="netcup-dns", description=__doc__.splitlines()[0])
    ap.add_argument("-e", "--env-file", help="KEY=VALUE file with NETCUP_* creds")
    ap.add_argument("--dry-run", action="store_true", help="show diff, do not send")
    ap.add_argument("domain", help="zone, e.g. syntax-fehler.de")
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list", help="print current zone")
    p_json = sub.add_parser("json", help="print current zone as JSON array")
    p_json.add_argument("-o", "--out", help="write to file instead of stdout")

    def crud(parser: argparse.ArgumentParser) -> None:
        parser.add_argument("hostname")
        parser.add_argument("type")
        parser.add_argument("destination")
        parser.add_argument("--ttl", type=int, default=None)
        parser.add_argument("--priority", default=None)

    p_add = sub.add_parser("add", help="add one record (fails if it exists)")
    crud(p_add)
    p_set = sub.add_parser("set", help="upsert: replace all rows for host+type")
    crud(p_set)
    p_rm = sub.add_parser(
        "rm", help="delete rows for host+type (all if no destination)"
    )
    p_rm.add_argument("hostname")
    p_rm.add_argument("type")
    p_rm.add_argument("destination", nargs="?", default=None)

    p_pull = sub.add_parser("pull", help="write zone to a JSON file")
    p_pull.add_argument("file")
    p_push = sub.add_parser(
        "push", help="replace zone from a JSON file (rows absent there are deleted)"
    )
    p_push.add_argument("file")

    args = ap.parse_args(argv)
    client = NetcupClient(load_creds(args.env_file))
    client.login()
    try:
        if args.cmd == "list":
            print_zone(client.info_dns_records(args.domain))
            return 0
        if args.cmd == "json":
            zone = client.info_dns_records(args.domain)
            text = json.dumps(zone, indent=2)
            if args.out:
                with open(args.out, "w", encoding="utf-8") as fh:
                    fh.write(text + "\n")
                print(f"wrote {args.out} ({len(zone)} records)")
            else:
                print(text)
            return 0
        if args.cmd == "pull":
            zone = client.info_dns_records(args.domain)
            with open(args.file, "w", encoding="utf-8") as fh:
                json.dump(zone, fh, indent=2)
                fh.write("\n")
            print(f"wrote {args.file} ({len(zone)} records)")
            return 0
        if args.cmd == "push":
            with open(args.file, encoding="utf-8") as fh:
                desired = [normalize_record(r) for r in json.load(fh)]
            return run_push(client, args.domain, desired, args.dry_run)

        host = normalize_hostname(args.domain, args.hostname)
        row: Record = {
            "hostname": host,
            "type": args.type.upper(),
            "destination": args.destination,
            "priority": getattr(args, "priority", None) or "0",
            "ttl": getattr(args, "ttl", None),
            "id": None,
        }
        current = client.info_dns_records(args.domain)
        if args.cmd == "add":
            if any(key(r) == key(row) for r in current):
                raise NetcupError(
                    f"{host} {row['type']} {row['destination']} already exists "
                    "(use set, or rm first)"
                )
            desired = current + [row]
        elif args.cmd == "set":
            kept = [
                r
                for r in current
                if not (r["hostname"] == host and r["type"] == row["type"])
            ]
            desired = kept + [row]
        else:  # rm

            def matches(r: Record) -> bool:
                return (
                    r["hostname"] == host
                    and r["type"] == row["type"]
                    and (
                        args.destination is None
                        or r["destination"] == row["destination"]
                    )
                )

            if not any(matches(r) for r in current):
                print("nothing to delete")
                return 0
            desired = [r for r in current if not matches(r)]
        return run_push(client, args.domain, desired, args.dry_run)
    finally:
        client.logout()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except NetcupError as err:
        print(f"error: {err}", file=sys.stderr)
        sys.exit(1)
