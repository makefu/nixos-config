{
    services.ollama = {
        enable = true;
        acceleration = "cuda";
    };
    services.nextjs-ollama-llm-ui = {
        enable = true;
        port = 3142;
    };
}
