{pkgs, ... }:
let
  uiport = 11435;
  port = 11434;
  home = "/data/ollama"; # on wbob
in {
  services.ollama = {
    enable = true;
    #acceleration = false; # CPU
    host = "0.0.0.0";
    package = pkgs.ollama-cpu;
    inherit port home;
  };
  services.nextjs-ollama-llm-ui = {
    enable = true;
    hostname = "0.0.0.0";
    port = uiport;
  };
  systemd.tmpfiles.rules = [
    "d ${home} 0777 root root - -"
  ];
  networking.firewall.allowedTCPPorts = [ uiport port ];
}
