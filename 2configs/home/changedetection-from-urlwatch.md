# Migrating the urlwatch watchlist to changedetection.io

`2configs/urlwatch/` (module `krebs.urlwatch`, inherited from stockholm)
was removed together with the stockholm flake input. omo already runs
changedetection.io (`2configs/home/changedetection.nix`, reachable at
`http://change.euer`), which supersedes it.

## What urlwatch did

- systemd timer `urlwatch.timer`, `OnCalendar = *-*-* 03,15:13:37`
- one HTTP GET per entry in `krebs.urlwatch.urls`, diffed against the
  previous body in `/var/lib/urlwatch/.urlwatch/cache`
- `hooks.py` pretty-printed JSON for `api.github.com` URLs so that the
  diff was line-based instead of one giant line
- non-empty diffs were piped into `/run/wrappers/bin/sendmail -t`, i.e.
  the whole thing depended on a local exim that omo has not run for a
  while — in practice the mails have not been arriving.

## Target shape in changedetection.io

changedetection.io keeps watches in its own database
(`/var/lib/changedetection-io`), not in Nix. Migration is therefore a
one-time data entry job in the web UI (or via its API), not a config
change. Recommended layout:

1. **Tags** mirroring the old grouping: `nixpkgs-maintenance` (github
   release feeds), `pypi`, `misc`.
2. **Global default** `Recheck time` 12h — the old timer fired twice a
   day; nothing in the list moves faster than that.
3. **Notification** — do not reintroduce sendmail. Point
   changedetection.io's notification URL at the ntfy instance that the
   alerting stack already uses:
   `ntfy://ntfy.euer/urlwatch` (set it once under Settings →
   Notifications so every watch inherits it).

### github release feeds

The old `grss` helper watched `https://github.com/<repo>/releases.atom`
and dropped the `<updated>`, `<media:thumbnail>`, `Continuous build`
and `Travis CI build log:` noise. In changedetection.io this becomes a
watch on the same atom URL with

- *Filters & Triggers* → CSS/XPath selector `//entry/title` (only
  release names, which drops the timestamp/thumbnail churn outright), or
- *Ignore text* lines `Continuous build` and `Travis CI build log:`

Repos: `amadvance/snapraid`, `radare/radare2`, `ovh/python-ovh`,
`embray/d2to1`, `vicious-widgets/vicious`,
`rapid7/metasploit-framework`, `GothenburgBitFactory/taskserver`,
`GothenburgBitFactory/taskwarrior`, `mhagger/cvs2svn`.

Consider replacing these with `nvchecker` or the GitHub release
notification instead — nine atom feeds is most of what urlwatch was
still doing, and github can push that itself.

### JSON endpoints (replaces hooks.py)

`https://api.github.com/repos/naim94a/udpt/commits`
`https://api.github.com/repos/dirkvdb/ps3netsrv--/commits`

changedetection.io has the equivalent of the old `JsonFilter` built in:
set the watch's *Filters & Triggers* → `json:$[0].sha` (or
`json:$[*].commit.message`). No hook file needed. Both repos have been
dead for years — check before recreating them.

### plain page watches

Straight one-to-one watches, no filter:

- `https://pypi.python.org/simple/{bepasty,devpi-client,sqlalchemy_migrate,xstatic,pyserial,semantic_version}/`
- `http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/`
- `https://erdgeist.org/gitweb/opentracker/info/refs?service=git-upload-pack`
- `http://www.iozone.org/src/current/`

The pypi `/simple/` indexes are better served by
`https://pypi.org/rss/project/<name>/releases.xml`, which is stable
markup and does not rewrite the whole page on every upload.

## Cleanup after migration

- `/var/lib/urlwatch` on omo can be deleted once the watches exist.
- the `urlwatch` system user is gone with the module; nothing else
  referenced its uid.
