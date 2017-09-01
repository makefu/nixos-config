{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    obs-studio
    studio-link
    audacity
    owncloudclient
  ];
}
