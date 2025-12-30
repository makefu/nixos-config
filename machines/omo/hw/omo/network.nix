let
    primaryInterface = "enp2s0";
in {
    makefu.server.primary-itf = primaryInterface;
    systemd.network.wait-online.ignoredInterfaces = [
        "podman0" "podman1" "podman2" "podman3"
        "veth0@if2" "veth1@if2" "veth2@if2" "veth2@if2"
        "wiregrill" "retiolum"
];
}
