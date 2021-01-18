{
  #               +                                       +
  #               |                                       |
  #               |                                       |
  #               v                                       v
  #          80, 443 TCP                          443 TCP, 10000 UDP
  #       +--------------+                     +---------------------+
  #       |  nginx       |  5222, 5347 TCP     |                     |
  #       |  jitsi-meet  |<-------------------+|  jitsi-videobridge  |
  #       |  prosody     |         |           |                     |
  #       |  jicofo      |         |           +---------------------+
  #       +--------------+         |
  #                                |           +---------------------+
  #                                |           |                     |
  #                                +----------+|  jitsi-videobridge  |
  #                                |           |                     |
  #                                |           +---------------------+
  #                                |
  #                                |           +---------------------+
  #                                |           |                     |
  #                                +----------+|  jitsi-videobridge  |
  #                                            |                     |
  #                                            +---------------------+

  # This is a one server setup
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.euer.krebsco.de";

    # JItsi COnference FOcus is a server side focus component used in Jitsi Meet conferences.
    # https://github.com/jitsi/jicofo
    jicofo.enable = true;

    # Whether to enable nginx virtual host that will serve the javascript application and act as a proxy for the XMPP server.
    #  Further nginx configuration can be done by adapting services.nginx.virtualHosts.<hostName>. When this is enabled, ACME
    #  will be used to retrieve a TLS certificate by default. To disable this, set the
    #  services.nginx.virtualHosts.<hostName>.enableACME to false and if appropriate do the same for
    #  services.nginx.virtualHosts.<hostName>.forceSSL.
    nginx.enable = true;

    # https://github.com/jitsi/jitsi-meet/blob/master/config.js
    config = {
      enableWelcomePage = true;
      defaultLang = "en";
    };

    # https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js
    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 10000 ];
  };

}
