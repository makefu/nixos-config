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
