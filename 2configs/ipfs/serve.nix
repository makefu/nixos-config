{
  imports =[
    ./hetzner-share.nix
  ];
  networking.firewall.allowedTCPPorts = [ 4001 ];
  networking.firewall.allowedUDPPorts = [ 4001 ]; # QUIC
  services.kubo = {
    enable = true;
    dataDir = "/media/ipfs";
    settings = {
      Experimental.FilestoreEnabled = true;
      Datastore.StorageMax = "100GB";
      Swarm = {
        ConnMgr = {
          LowWater = 100;
          HighWater = 400;
          GracePeriod = "20s";
        };
        Transports.Network.TCP = true;
        Transports.Network.QUIC = true;
        ResourceMgr = {
          Enabled = true;
          MaxMemory = "2GB";
        };
        RelayClient.Enabled = false;
        RelayService.Enabled = false;
      };
      # dhtclient: announces our provider records (so peers can find us
      # by CID) but does not serve DHT routing queries for others.
      Routing.Type = "dhtclient";
    };
  };
}
