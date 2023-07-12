{
  # mosquitto_pub -t /bam/sonoffs/cmnd/OtaUrl -m "http://192.168.8.11/sonoff.bin"
  # mosquitto_pub -t /bam/sonoffs/cmnd/upgrade -m "6.5.0"
  # wget https://github.com/arendst/Sonoff-Tasmota/releases/download/v6.5.0/sonoff.bin
  # wget https://github.com/arendst/Sonoff-Tasmota/releases/download/v6.5.0/sonoff-minimal.bin
  services.nginx = {
    enable = true;
    virtualHosts."192.168.8.11" = {
      root = "/var/www/tasmota";
      extraConfig = ''
          autoindex on;
      '';
    };
  };
}
