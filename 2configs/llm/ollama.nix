let
  uiport = 11435;
  port = 11434;
in {
  services.ollama = {
    enable = true;
    acceleration = false; # CPU
    host = "0.0.0.0";
    inherit port;
    home = "/data/ollama"; # on wbob
  };
  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = uiport;
  };
  networking.firewall.allowedTCPPorts = [ uiport port ];
}
