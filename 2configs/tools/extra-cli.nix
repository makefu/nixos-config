{pkgs, ...}: {
    users.users.makefu.packages = with pkgs;[
        btop
    ];
}
