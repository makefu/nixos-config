{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user;
  version = "5.0.4";
  rev = "102546";
  vboxguestpkg = pkgs.fetchurl {
        url = "http://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}-${rev}.vbox-extpack";
        sha256 = "1ykwpjvfgj11iwhx70bh2hbxhyy3hg6rnqzl4qac7xzg8xw8wqg4";
      };
in {
  #inherit vboxguestpkg;
  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;

  users.extraGroups.vboxusers.members = [ "${mainUser.name}" ];
  environment.systemPackages = [ vboxguestpkg ];
}
