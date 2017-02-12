{
  services.dnscrypt-proxy.enable = true;
  networking.extraResolvconfConf = ''
    name_servers='127.0.0.1'
  '';
}
