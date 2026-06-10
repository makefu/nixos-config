{
  imports =[
    ./hetzner-share.nix
    ./serve.nix
  ];
  services.kubo = {
    dataDir = "/media/ipfs";
  };
}
