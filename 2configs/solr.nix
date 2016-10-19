{ config, lib, pkgs, ... }:

# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)
with config.krebs.lib;
let
  solrHome = "/var/db/solr";
in {
  imports = [ ];
  users.users.solr = {
    home = solrHome;
    uid = genid "solr";
    createHome = true;
    group = "solr";
  };
  users.groups.solr.gid = genid "solr";

  services.solr = {
    enable = true;
    inherit solrHome;
    user = "solr";
    group = "solr";
  };
}
