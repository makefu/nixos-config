{
  # https://docs.pipewire.org/page_module_raop_discover.html
  services.pipewire.extraConfig.pipewire."92-raop-discover" = {
    "context.modules" = [
      {
        name = "libpipewire-raop-discover";
        args = {
          "stream.rules" = [
            { matches = [
                { raop.ip = "~.*";
                }
              ];
              actions = {
                create-stream = {
                  stream.props = {};
                };
              };
            }
          ];
        };
      }
    ];
  };
}
