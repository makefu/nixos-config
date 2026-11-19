# Globally disable HTTP/2 for every nginx vhost on this host.
# The nginx module defaults virtualHosts.<name>.http2 to true and emits
# `http2 on;` in every TLS server block, so it has to be forced off centrally
# instead of per snippet (the vhosts are declared all over 2configs/).
#
# Implementation: re-declare the option with an `apply` — it post-processes
# the merged value of all virtualHosts definitions without defining the
# option itself (defining it from its own config would recurse infinitely).
{ lib, ... }:
{
  options.services.nginx.virtualHosts = lib.mkOption {
    apply = vhosts: lib.mapAttrs (_: vhost: vhost // { http2 = false; }) vhosts;
  };
}
