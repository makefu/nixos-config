{config, ... }:
{
  state = [ config.services.taskserver.dataDir ];
  services.taskserver.enable = true;
  services.taskserver.fqdn = config.krebs.build.host.name;
  services.taskserver.listenHost = "::";
  services.taskserver.organisations.home.users = [ "makefu" ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport 53589 -j ACCEPT
    ip6tables -A INPUT -i retiolum -p tcp --dport 53589 -j ACCEPT
  '';
}
