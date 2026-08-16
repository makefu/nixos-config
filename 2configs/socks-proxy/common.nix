# Shared parameters for the on-demand socks5 tunnel to gum.
# Not a NixOS module — imported as plain data by client.nix / server.nix.
{
  # dedicated login on both ends, restricted to port forwarding on the server
  user = "socksproxy";

  # public half of clan secret <host>-socks-proxy.key
  clientPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1H/0YcV7r3hGVq3IWiaGK0xGmo0d5vKoKYdZ3CTyXd socks-proxy@x";

  # reached over the public internet: the tunnel must also work when
  # retiolum/tinc is down or the local network blocks the mesh
  serverHost = "gum.krebsco.de";

  # what foxyproxy/firefox connects to
  socksPort = 23456;
  # backend port `ssh -D` binds; only systemd-socket-proxyd talks to it
  tunnelPort = 23457;

  # tear the tunnel down after this much idle time on the socket
  idleTimeout = "10min";
}
