let
    webport = 11435;
    port = 11434;
in{
    # nixpkgs.config.cudaSupport = true;
    services.ollama = {
        enable = true;
        inherit port;
        #acceleration = "cuda";
        acceleration = false;
    };
    services.nextjs-ollama-llm-ui = {
        enable = true;
        port = webport;
    };
    networking.firewall.allowedTCPPorts = [ port webport ];
}
