{
  services.dnscrypt-proxy.enable = true;
  services.dnscrypt-proxy.resolverName = "cs-de";
  networking.extraResolvconfConf = ''
    name_servers='127.0.0.1'
  '';
}
