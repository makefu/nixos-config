# x2 clevis + tang unlock setup

End-to-end recipe to set up ZFS root unlock on `x2` via clevis/tang against
the tang server at `192.168.111.11`.

Result: on boot, the systemd-initrd

1. brings up the wired uplink (see `x230/tang.nix`),
2. fetches the tang advertisement from `192.168.111.11:7654`,
3. uses clevis to decrypt `/etc/clevis/zfs-root.jwe` → the ZFS passphrase,
4. feeds that passphrase to ZFS to unlock `rpool/root`.

Wifi is no longer carried into initrd — `x230/wifi.nix` brings up NM-managed
wlan0 post-boot only. Tang unlock therefore requires wired LAN reachability.

The unlock secret is a **separate random keyfile**, not the user-typed
passphrase that was set at install time. Both stay valid concurrently
because ZFS allows only one key per encryption root — so we **rotate**
the rpool/root key to the new random secret. The old install-time
passphrase is overwritten; keep a printed copy somewhere safe before
rotating if you want a fallback.

## 0. Threat model recap

- Repo: secret is sops-encrypted (age `x2_host` + your GPG). Safe in git.
- `/run/secrets/`: tmpfs, root-only. Safe while the system runs.
- `/etc/clevis/zfs-root.jwe`: tang-encrypted JWE on `rpool/root`, copied
  into the initramfs cpio on the unencrypted ESP at bootloader-install
  time. Recovering the plaintext requires reaching the tang server on the
  LAN. ESP exposure alone is not sufficient.
- Tang server (`192.168.111.11`): trusted. Anyone with LAN access to it
  can decrypt the JWE — keep it on a network only your boxes can reach.

## 1. Generate the unlock keyfile (workstation)

Random 32-byte hex string. ZFS passphrase must be 8–512 bytes; hex is fine.

```sh
KEY=$(openssl rand -hex 32)
printf '%s' "$KEY" > tmp/x2-zfs-root.key   # no trailing newline
```

`tmp/` is gitignored. The trailing-newline issue is critical — `zfs` treats
the entire file content as the passphrase, newline included.

## 2. Store the keyfile in clan secrets

Use the clan CLI — it writes `sops/secrets/zfs-root.key/{secret,machines/x2,users/makefu}`
and commits the result. clan-core auto-wires the entry into
`config.sops.secrets."zfs-root.key"` for every machine listed under
`machines/` — no extra nix glue needed.

```sh
nix shell .#euer-add-device --command \
  sh -c 'cat tmp/x2-zfs-root.key | clan secrets set --machine x2 --user makefu zfs-root.key'
```

Verify:

```sh
nix shell .#euer-add-device --command sh -c 'clan secrets get zfs-root.key' | wc -c   # 64
```

Deploy:

```sh
nixos-rebuild --flake .#x2 switch --target-host root@x2.euer
```

After activation, on x2:

```sh
ssh root@x2.euer 'wc -c /run/secrets/zfs-root.key'   # 64
```

Wipe the workstation copy:

```sh
shred -u tmp/x2-zfs-root.key
```

## 3. Rotate the rpool/root key on x2

On the host, with rpool already imported and the dataset unlocked:

```sh
ssh root@x2.euer
zfs get -H -o value keystatus rpool/root      # available
zfs change-key -o keyformat=passphrase \
               -o keylocation=file:///run/secrets/zfs-root.key \
               rpool/root
zfs get -H -o value keylocation rpool/root    # file:///run/secrets/zfs-root.key
```

`zfs change-key` re-wraps the master encryption key with the new
passphrase. It does **not** re-encrypt the data — fast, no downtime.

`keylocation=file://...` makes future boots try to read the keyfile
directly. We do **not** want that for the boot path (the file is on the
encrypted root and not visible in initrd). Reset it to prompt so
`boot.zfs.requestEncryptionCredentials` keeps working as a manual fallback
if clevis fails:

```sh
zfs set keylocation=prompt rpool/root
```

The wrapped master key is now bound to the contents of
`/run/secrets/zfs-root.key`.

## 4. Build the tang JWE on x2

The JWE must be produced **from the same byte stream** that zfs accepts as
the passphrase. Generate it on x2 so the keyfile never leaves an encrypted
disk in plaintext.

Drop into a single nix shell with every tool the step needs:

```sh
ssh root@x2.euer
nix shell nixpkgs#clevis nixpkgs#jose nixpkgs#curl nixpkgs#diffutils
```

Inside that shell:

```sh
mkdir -p /etc/clevis

# audit the advertised tang thumbprint(s) — must match the tang host
curl -fsS http://192.168.111.11:7654/adv \
  | jose fmt -j- -g payload -y -o- \
  | jose jwk thp -i-

# encrypt the keyfile to tang ('-y' = trust adv, only safe after audit)
clevis encrypt tang '{"url":"http://192.168.111.11:7654"}' -y \
  < /run/secrets/zfs-root.key \
  > /etc/clevis/zfs-root.jwe.new

# round-trip against tang — must reproduce the keyfile byte-for-byte
clevis decrypt < /etc/clevis/zfs-root.jwe.new \
  | cmp - /run/secrets/zfs-root.key && echo OK

# swap in
install -m 0444 -o root -g root \
  /etc/clevis/zfs-root.jwe.new /etc/clevis/zfs-root.jwe
rm /etc/clevis/zfs-root.jwe.new
exit
```

Cross-check the tang server's thumbprints (separate session). Tang
stores each JWK as `<thumbprint>.jwk`, so `ls` is enough:

```sh
ssh root@192.168.111.11 'ls /var/lib/tang/'
```

Each filename (sans `.jwk`) must appear in the audit pipeline output.

## 5. Persist the JWE in the repo

`tang.nix` references `/etc/clevis/zfs-root.jwe` via
`boot.initrd.clevis.devices."rpool/root".secretFile`. The NixOS clevis
module rewrites this to
`boot.initrd.secrets."/etc/clevis/zfs-root.jwe" = "/etc/clevis/zfs-root.jwe";`
— i.e. the file on `rpool/root` (where `/etc` lives, mounted while
userspace runs) is **read at bootloader-install time** by
`append-initrd-secrets` and baked into the initramfs cpio extension on
the ESP. At boot the kernel concatenates that cpio onto the unencrypted
initramfs and the JWE appears at `/etc/clevis/zfs-root.jwe` *inside the
initramfs root* — not from a mounted `/etc`. clevis-luks-askpass reads it
from there before rpool is unlocked.

The repo's `secrets/x2/etc/clevis/zfs-root.jwe` is the deploy-once
plaintext copy used during initial install (when there is no rpool yet to
read from). JWE is tang-public-key encrypted — safe to commit.

Pull the new JWE back to the workstation:

```sh
scp root@x2.euer:/etc/clevis/zfs-root.jwe \
    secrets/x2/etc/clevis/zfs-root.jwe
git add secrets/x2/etc/clevis/zfs-root.jwe
git commit -m 'x2: rotate clevis zfs-root JWE to tang 192.168.111.11'
```

For subsequent rotations just overwrite `/etc/clevis/zfs-root.jwe`
directly on the target as in step 4.

## 6. Verify before rebooting

```sh
ssh root@x2.euer
nix shell nixpkgs#clevis nixpkgs#jose nixpkgs#curl nixpkgs#diffutils
```

Inside the shell:

```sh
ls -la /etc/clevis/zfs-root.jwe
curl -fsS http://192.168.111.11:7654/adv > /dev/null && echo tang-ok
diff <(clevis decrypt < /etc/clevis/zfs-root.jwe) /run/secrets/zfs-root.key \
  && echo match
zfs get -H -o value keystatus,keyformat,keylocation rpool/root
exit
```

Expect:
- file present, mode `0444`
- `tang-ok`
- `match`
- keystatus `available`, keyformat `passphrase`, keylocation `prompt`

## 7. Reboot test

```sh
ssh root@x2.euer 'systemctl reboot'
```

Expected initrd flow (`journalctl -b -1 -u clevis-luks-askpass*` /
`systemd-journald` on next boot):

1. Wired NIC link comes up, systemd-networkd DHCP on `ether`.
2. `clevis-luks-askpass`/`clevis-zfs-askpass` fetches tang adv,
   decrypts `/etc/clevis/zfs-root.jwe`, pipes passphrase into zfs.
3. `rpool/root` keystatus becomes `available`; root mounts; userspace
   starts.
4. NetworkManager comes up post-boot and associates wlan0 against the
   profile from `x230/wifi.nix`.

If clevis fails (tang unreachable, JWE mismatch), you fall through to
the manual passphrase prompt from `boot.zfs.requestEncryptionCredentials`.
That prompt now expects the **new** key — keep a copy somewhere offline:

```sh
nix shell .#euer-add-device --command sh -c 'clan secrets get zfs-root.key'
```

## Rotation / re-pinning

To re-pin to a different tang server, or after tang key rotation on
`192.168.111.11`:

1. Re-run step 4 on x2 (same `/run/secrets/zfs-root.key`, new JWE).
2. Re-run step 5 to commit the new JWE.

No `zfs change-key` needed — the underlying passphrase is unchanged.
To rotate the passphrase itself: re-do steps 1–5 in order.


---

# Migration: tang 192.168.111.11 → 192.168.111.1 (router)

Same tang the omo root unlock already uses
(`machines/omo/hw/clevis-tang.nix`). Verified live 2026-09-29:

|Server|Port|Signature thp (S256)|
|---|---|---|
|192.168.111.11 (omo, `2configs/home/tang.nix`)|7654|`LFmP60wcKbkPc5pRYGxuQl698vPA5Hy12uSNyGJDEzU` + `k0LrvEgBveLQCpV_v6t1k4yLGbpOSQSIXOfr39RmlqI`|
|192.168.111.1 (router)|9090|`sKK4r8Nj28PEZu7KamrKEPeiV0X763_xy51EpicHF8s` + `oTmiw91lQRRFSXPXE_yZPCB7linqufE3pGJA2ei2S9M`|

The tang URL lives **only inside the JWE** (`clevis.tang.url` + pinned
`adv` in the protected header) — no `.nix` file references it.
`x230/tang.nix` points `boot.initrd.clevis.devices."rpool/root".secretFile`
at the live path `/etc/clevis/zfs-root.jwe`, which
`append-initrd-secrets` bakes into the UKI at each rebuild. So the
switch is: regenerate the JWE against the new server, then rebuild so
the new UKI carries it. **No `zfs change-key`, no data re-encryption**
— only the keyfile's tang-sealed ciphertext changes. The plaintext
key (`zfs-root.key` sops secret, `/run/secrets/zfs-root.key`) stays
byte-identical.

## M1. Reachability pre-check (from x2, and it implies stage-1)

```sh
ssh root@x2.euer 'curl -fsS http://192.168.111.1:9090/adv >/dev/null && echo router-tang-ok'
```

Stage-1 uses the same wired NIC + DHCP, so workspace reachability from
the host ⇒ initrd reachability.

## M2. Regenerate the JWE on x2  (DONE 2026-09-29 — this is the executed recipe)

Run as a script file on x2 (env vars do NOT survive `nix shell`, and the
config JSON must be built there):

```sh
cat > /tmp/mkjwe.sh <<'EOF'
set -e
curl -fsS http://192.168.111.1:9090/adv > /tmp/adv.json
T=$(cat /tmp/adv.json | jose fmt -j- -g payload -y -o- | jose jwk thp -i- | head -1)
echo "audited-thp=$T"
test "$T" = "sKK4r8Nj28PEZu7KamrKEPeiV0X763_xy51EpicHF8s" || { echo THP-MISMATCH; exit 1; }
jq -cn --argjson adv "$(cat /tmp/adv.json)" --arg thp "$T" \
  '{url:"http://192.168.111.1:9090",adv:$adv,thp:$thp}' > /tmp/cfg.json
clevis encrypt tang "$(cat /tmp/cfg.json)" -y \
  < /run/secrets/zfs-root.key > /etc/clevis/zfs-root.jwe.new
clevis decrypt < /etc/clevis/zfs-root.jwe.new | cmp - /run/secrets/zfs-root.key && echo ROUNDTRIP-OK
EOF
nix shell nixpkgs#clevis nixpkgs#jose nixpkgs#curl nixpkgs#jq --command sh /tmp/mkjwe.sh
```

Gotchas learned:
- `adv` must be the **verbatim full JWS** (`{payload,protected,signature}`)
  as served by `/adv` — a decoded payload or plain `jq .payload` (which is
  just the b64 string) makes clevis say "Advertisement is malformed!".
- `thp` is an encrypt-time check only; clevis does not store it in the JWE
  header (the old 111.11 JWE didn't have it either). What protects the boot
  path is the embedded `adv`: the initrd tang pin verifies the server's live
  advertisement against the pinned copy, so a swapped-in key/MITM can't
  redirect the unlock.

Then swap in (after backing up the current file):

```sh
cp -a /etc/clevis/zfs-root.jwe /root/zfs-root.jwe.pre-migration.bak
install -m 0444 -o root -g root /etc/clevis/zfs-root.jwe.new /etc/clevis/zfs-root.jwe
rm /etc/clevis/zfs-root.jwe.new
```

Executed artifacts: new JWE sha256
`cead26b4c0a3e27fc18868cd4917575adbb3632e1228284fe7399ffd62b721f2`
(1326 B, pins `url=http://192.168.111.1:9090`).

## M3. Rebuild the UKI (this is what activates the change)

```sh
clan machines update x2
```

The rebuild re-reads `/etc/clevis/zfs-root.jwe` and bakes it into the
new UKI on the ESP. The previous generation keeps the OLD JWE, so the
old omo tang stays a working fallback until that generation is GC'd.

## M4. Store the new JWE in sops + refresh deploy-once copy

The JWE is tang-public-key ciphertext (not sensitive), but sops is the
canonical copy (mirrors `omo-cryptroot.jwe` / `omo-cryptext.jwe`):

```sh
scp root@x2.euer:/etc/clevis/zfs-root.jwe /tmp/x2-zfs-root.jwe
cat /tmp/x2-zfs-root.jwe | clan secrets set --machine x2 --user makefu zfs-root.jwe
cp /tmp/x2-zfs-root.jwe secrets/x2/etc/clevis/zfs-root.jwe   # gitignored, install media only
```

`zfs-root.key` itself does NOT change. No git commit for the JWE —
`secrets/x2/` is gitignored; `clan secrets set` auto-commits
`sops/secrets/zfs-root.jwe/`.

## M5. Verify + reboot test

```sh
ssh root@x2.euer 'nix shell nixpkgs#clevis nixpkgs#diffutils --command \
  sh -c "clevis decrypt < /etc/clevis/zfs-root.jwe | cmp - /run/secrets/zfs-root.key && echo match"'
ssh root@x2.euer 'systemctl reboot'
```

If the router tang is ever down, the `keylocation=prompt` fallback
still takes the same key: `clan secrets get zfs-root.key`.

Cleanup option afterwards: once x2 boots on the router tang, omo's own
tang service (`2configs/home/tang.nix`, imported in
`machines/omo/config.nix`) has no remaining clients and can be dropped.

---

# Backups & recovery

## Where the old (192.168.111.11) JWE is kept

|Copy|Location|Notes|
|---|---|---|
|sops canonical|secret `zfs-root.jwe.old` (`sops/secrets/zfs-root.jwe.old/`, recipients `x2_host` age + makefu PGP)|`clan secrets get zfs-root.jwe.old`|
|workstation|`tmp/x2-zfs-root.jwe.old` (gitignored)|sha256 `91798286ef20aa6df670c51e1b017b87bf42df4c847c99e3b3b2fad3b35616e9`, 1327 B|
|repo deploy-once|`secrets/x2/etc/clevis/zfs-root.jwe.old` (gitignored)|install-media copy|
|on-host|`/root/zfs-root.jwe.pre-migration.bak` on x2|byte-identical to the sha256 above|

The new (192.168.111.1) active JWE: `/etc/clevis/zfs-root.jwe` on x2,
sops secret `zfs-root.jwe`, `secrets/x2/etc/clevis/zfs-root.jwe`,
sha256 `cead26b4c0a3e27fc18868cd4917575adbb3632e1228284fe7399ffd62b721f2`.

## Recovery scenarios

### Router tang (192.168.111.1) down/unreachable at boot

Initrd clevis decrypt fails → falls through to the interactive
`keylocation=prompt` passphrase prompt (`boot.zfs.requestEncryptionCredentials`).
Type/paste the keyfile contents:

```sh
clan secrets get zfs-root.key        # 64 hex chars, no newline
```

Then boot normally; the plaintext key also lives at
`/run/secrets/zfs-root.key` (sops) once the system is up.

### Must revert to the old tang (192.168.111.11, omo)

The old JWE wraps the SAME keyfile, so reverting is just putting the old
ciphertext back — no zfs operations:

```sh
clan secrets get zfs-root.jwe.old > /tmp/zfs-root.jwe.old
scp /tmp/zfs-root.jwe.old root@x2.lan:/tmp/
ssh root@x2.lan 'install -m 0444 -o root -g root /tmp/zfs-root.jwe.old /etc/clevis/zfs-root.jwe'
clan machines update x2    # re-bake UKI with the old JWE
```

Verify before reboot: `clevis decrypt < /etc/clevis/zfs-root.jwe |
cmp - /run/secrets/zfs-root.key`. Note omo's tang service must still be
running (`2configs/home/tang.nix`) for the old JWE to decrypt.

### Both tang servers dead AND offline unlock needed (disk in another box)

The JWEs are ciphertext-only; the plaintext is everywhere-else canonical:

```sh
clan secrets get zfs-root.key > /tmp/keyfile
zfs load-key -a /tmp/keyfile rpool/root   # or paste at 'zfs mount' prompt
```

### Tang server key rotation (either server)

Existing JWEs stop decrypting (old signing/ECMR JWKs get replaced).
Re-run M2 against the fresh `/adv`, audit the NEW thumbprint out-of-band
before trusting, re-bake (M3), re-store (M4). Keep the pre-rotation JWE
as `.old` until one clean boot proves the new one.
