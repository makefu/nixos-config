#!/usr/bin/env python3
"""Patch studio-link binary in-place to relocate the OnAir button and widen Record."""
import sys

path = sys.argv[1]
data = bytearray(open(path, "rb").read())

start_marker = b"<!doctype html>"
end_marker = b"</html>\n"
start = data.find(start_marker)
if start < 0:
    raise SystemExit("HTML start marker not found")
end = data.find(end_marker, start)
if end < 0:
    raise SystemExit("HTML end marker not found")
end += len(end_marker)
orig = bytes(data[start:end])
orig_len = end - start

onair_block = (
    b'\t\t\t\t\t\t\t<button class="btn btn-secondary btn-sm float-right d-none"'
    b' style="margin-left: 6px; min-height: 35px;" id="btn-onair">\n'
    b'\t\t\t\t\t\t\t\t<i class="fa fa-rss" aria-hidden="true"></i> OnAir\n'
    b'\t\t\t\t\t\t\t</button>\n'
)
if onair_block not in orig:
    raise SystemExit("OnAir button block not found - upstream changed?")
new = orig.replace(onair_block, b"", 1)

more_link = b'<a role="button" data-toggle="collapse" href="#card-settings"><b>More...</b></a>\n'
inserted = (
    more_link
    + b'\t\t\t\t\t\t\t<button class="btn btn-secondary btn-sm float-right d-none"'
    b' style="min-height:35px" id="btn-onair">\n'
    b'\t\t\t\t\t\t\t\t<i class="fa fa-rss" aria-hidden="true"></i> OnAir\n'
    b'\t\t\t\t\t\t\t</button>\n'
)
if more_link not in new:
    raise SystemExit("More... toggle link not found")
new = new.replace(more_link, inserted, 1)

rec_old = b'style="margin-left: 6px; min-height: 35px;" id="btn-record"'
rec_new = b'style="margin-left:6px;min-height:35px;min-width:240px" id="btn-record"'
if rec_old not in new:
    raise SystemExit("Record button style not found")
new = new.replace(rec_old, rec_new, 1)

if len(new) > orig_len:
    raise SystemExit(f"patched HTML too large: {len(new)} > {orig_len}")

pad = orig_len - len(new)
if pad:
    if pad >= 7:
        filler = b"<!--" + b" " * (pad - 7) + b"-->"
    else:
        filler = b" " * pad
    new = new.replace(b"</html>", filler + b"</html>", 1)

if len(new) != orig_len:
    raise SystemExit(f"length mismatch {len(new)} vs {orig_len}")

data[start:end] = new
open(path, "wb").write(data)
print(f"patched {path}: {orig_len} bytes preserved")
