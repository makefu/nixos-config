# omo Secure Boot auto-enrollment failure — investigation report (2026-09-28)

Investigation-only; no changes were made on the host.

## TL;DR

Two different key sets exist on omo. The UKIs and fallback bootloaders are signed
with the **current** sbctl bundle (`/var/lib/sbctl`, "set B", created 2026-09-16
01:55 CEST), but the systemd-boot auto-enrollment payload
`/boot/loader/keys/auto/{PK,KEK,db}.auth` still contains an **older, orphaned**
key set ("set A", created 2026-09-16 01:21 CEST, one generation earlier).

On reboot the firmware is in Setup Mode (no keys enrolled, vendor keys cleared),
so systemd-boot finds `/loader/keys/auto` and enrolls set A. The firmware `db`
then contains the wrong Database Key, and the next boot's UKI — signed with set
B — fails verification: "Secure Boot signature / security violation". Clearing
keys (or disabling Secure Boot) in the AMI setup makes the machine boot again,
and the loop repeats on every reboot while Setup Mode is active.

## Evidence

### Live firmware state

- `sbctl status`: Setup Mode Enabled, Secure Boot Disabled, Vendor Keys: none
- `/sys/firmware/efi/efivars/` contains only `*Default` variables — no live
  `PK-*` / `KEK-*` / `db-*` exist (kernel exposes them only when enrolled)
- `SetupMode` = 1, `SecureBoot` = 0
- `BootOrder` = `{0001}`, `BootCurrent` = `0001` (fallback `\EFI\BOOT\BOOTX64.EFI`)

### Key material cross-check

| Artifact | Cert serial | notBefore (UTC) | Set |
|---|---|---|---|
| `/var/lib/sbctl/keys/PK/PK.pem` | `CEEC4486C2B6E1846F9C7E4E7B0F4D07` | 2026-09-15 23:55:23 | B |
| `/var/lib/sbctl/keys/KEK/KEK.pem` | `F86C8B2AE9FF8279E1A8139666A6913C` | 2026-09-15 23:55:25 | B |
| `/var/lib/sbctl/keys/db/db.pem` (fp `BF:21:55:81…DB:1C`) | `B1A8494669A565EEC24D6E6E4136A5A4` | 2026-09-15 23:55:27 | B |
| cert embedded in `/boot/loader/keys/auto/PK.auth` | `C7C8ABBD64D913B39387C9520FFE8371` | 2026-09-15 23:21:33 | **A ✗** |
| cert embedded in `/boot/loader/keys/auto/KEK.auth` | `63B26DD19ADEA09AF4D2F14E179BB05E` | 2026-09-15 23:21 | **A ✗** |
| cert embedded in `/boot/loader/keys/auto/db.auth` | `C860C418A3BBBA9611146142C300E85C` | 2026-09-15 23:21:36 | **A ✗** |
| UKI `nixos-generation-12-…efi` `.sbs` signature | `B1A84946…` (= sbctl db) | — | B ✓ |
| `BOOTX64.EFI`, `systemd-bootx64.efi` signatures | `B1A84946…` (= sbctl db) | — | B ✓ |
| UKIs gen 5–11 (`sbctl verify` all ✓) | set B | — | B ✓ |

File timestamps:

- `/boot/loader/keys/auto/*.auth` mtime: 2026-09-16 **01:21:36** CEST (= set A, 23:21 UTC)
- `/var/lib/sbctl/GUID` + `keys/*`: 2026-09-16 **01:55** CEST (= set B, 23:55 UTC)

Keys were (re)generated ~34 min **after** the `.auth` files were exported; the
`.auth` payload was never regenerated.

### Why the mismatch is stuck (dead code path)

Lanzaboote module (pinned rev `f4b2a2f0ff3be919fabe440c7144cb6d144f2049`,
`nix/modules/lanzaboote.nix:546-583`) guards `prepare-sb-auto-enroll` with:

```
ConditionPathExists = [ "!/boot/loader/keys/auto/PK.auth" … ]
```

Once the `.auth` files exist the unit never regenerates them — confirmed in the
journal on every boot (`prepare-sb-auto-enroll.service skipped, unmet condition
check ConditionPathExists=!/boot/loader/keys/auto/db.auth`; same for
`generate-sb-keys` via `ConditionPathExists=!/var/lib/sbctl/keys`). The module
never deletes stale `.auth` files, so any key rotation (`sbctl rotate-keys` /
manual `sbctl create-keys`) without also clearing `/boot/loader/keys/auto/`
permanently desynchronizes the auto-enroll payload from the signing keys.

Journal boot history corroborates the failure loop during bring-up: boots at
Sep 16 02:32 / 02:45 / 03:05 CEST lasted only 4–6 s (enrollment → reboot →
signature violation → clear/disable keys); the first long stable boot starts at
03:11 CEST, after Secure Boot was effectively left disabled.

### Consistent (non-problematic) material

- Config matches the live bundle: `2configs/security/secure-boot.nix` +
  `flake.nix:193` (`boot.lanzaboote.pkiBundle = "/var/lib/sbctl"`,
  `autoGenerateKeys.enable`, `autoEnrollKeys.enable` + `autoReboot`, MS KEK
  disabled) ↔ live bundle ↔ UKI signatures (all set B).
- No stale `/etc/secureboot` bundle on the host.
- No sops-stored Secure Boot keys; keys are generated on-host.
- `/var/lib/sbctl/files.json` empty is normal — lanzaboote signs via `lzbt`,
  not through the sbctl file database.

Only mismatch: the ESP `.auth` auto-enrollment payload (set A).

## Recommended fix (not applied)

1. Ensure firmware is in Setup Mode / keys cleared (already the case).
2. On omo: `rm /boot/loader/keys/auto/{PK,KEK,db}.auth`
3. `systemctl start prepare-sb-auto-enroll.service` — regenerates the `.auth`
   files from the current set B bundle, re-signs ESP artifacts, reboots
   (SuccessAction=reboot); or manually `sbctl enroll-keys` and remove the auto
   directory.
4. Optional hardening: whenever keys are rotated, always clear
   `/boot/loader/keys/auto/` in the same step — upstream lanzaboote has no
   cleanup, so this desync recurs on every manual rotation.
