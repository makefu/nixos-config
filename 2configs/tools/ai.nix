{
  home-manager.users.makefu.imports = [ ./home-manager/ai.nix ];
  state = [ "/home/makefu/.claude.json" ];
}
