{
  imports =[
    ./hetzner-share.nix
    ./local-serve.nix
  ];
  services.kubo = {
    dataDir = "/media/ipfs";
  };
}
