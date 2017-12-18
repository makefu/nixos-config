{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [ iproute vpn-ws ];
  # vpn-ws-client  vpnws wss://localhost/vpn --no-verify --exec "ip link set vpnws up;ip addr add 10.244.1.2/24 dev vpnws"
  networking.interfaces.vpnws = {
    virtual = true;
    virtualType = "tap";
  };
}
