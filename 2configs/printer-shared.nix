{ pkgs, config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.interfaces = [ config.makefu.server.primary-itf ];
  services.avahi.ipv6 = false;
  services.avahi.nssmdns = true;
  # via  https://github.com/tjfontaine/airprint-generate/
  # environment.etc."avahi/services/samsung_scx2300.service".text 
  nixpkgs.config.packageOverrides = pkgs: rec {
    avahi = pkgs.stdenv.lib.overrideDerivation pkgs.avahi (oldAttrs: {
      postFixup = let
	    cfg = pkgs.writeText "airprint-scx3200.service" ''<?xml version="1.0" ?><!DOCTYPE service-group  SYSTEM 'avahi-service.dtd'><service-group><name replace-wildcards="yes">AirPrint Samsung_SCX-3200_Series @ %h</name><service><type>_ipp._tcp</type><subtype>_universal._sub._ipp._tcp</subtype><port>631</port><txt-record>txtvers=1</txt-record><txt-record>qtotal=1</txt-record><txt-record>Transparent=T</txt-record><txt-record>URF=none</txt-record><txt-record>rp=printers/Samsung_SCX-3200_Series</txt-record><txt-record>note=Samsung SCX-3200 Series</txt-record><txt-record>product=(GPL Ghostscript)</txt-record><txt-record>printer-state=3</txt-record><txt-record>printer-type=0x801044</txt-record><txt-record>pdl=application/octet-stream,application/pdf,application/postscript,application/vnd.cups-raster,image/gif,image/jpeg,image/png,image/tiff,image/urf,text/html,text/plain,application/vnd.adobe-reader-postscript,application/vnd.cups-command</txt-record></service></service-group>'';
      in ''
        cp ${cfg} $out/etc/avahi/services/airprint-scx3200.service
      '';
    });
  };

  # only allowed in local network
  services.printing = {
    enable = true;
    browsing = true;
    #avahiEnabled = true;
    defaultShared = true;
    listenAddresses = [ "*:631" ];
    drivers = [
      pkgs.samsungUnifiedLinuxDriver
    ];
  };

  # scanners are printers just in reverse anyway
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.samsungUnifiedLinuxDriver ];
}
