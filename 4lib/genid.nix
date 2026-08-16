# Stable uid/gid generator, inherited from stockholm's lib.
#
# The ids it returns are baked into on-disk ownership (samba shares,
# torrent state, ...), so the algorithm must stay bit-identical:
#
#   genid s = fold16 ([ (16*n0 + n1 + 1) mod 256 ] ++ [ n2 .. n7 ])
#
# where n0..n7 are the last eight hex digits of sha1(s). The +2^24 bias
# keeps every result above the statically assigned ids in nixpkgs'
# misc/ids.nix as well as above nobody/nogroup.
{ lib }:
let
  hexvals = lib.listToAttrs (
    lib.imap0 (i: c: { name = c; value = i; })
      (lib.stringToCharacters "0123456789abcdef"));

  nibbles = s:
    map (c: hexvals.${c})
      (lib.stringToCharacters
        (builtins.substring 32 8 (builtins.hashString "sha1" s)));
in
s:
let
  x = nibbles s;
  # the two leading nibbles are folded into one byte, hence the bias
  head = lib.mod (16 * builtins.elemAt x 0 + builtins.elemAt x 1 + 1) 256;
in
lib.foldl' (acc: i: acc * 16 + i) 0 ([ head ] ++ lib.drop 2 x)
