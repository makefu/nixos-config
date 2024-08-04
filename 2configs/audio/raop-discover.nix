{
  # https://docs.pipewire.org/page_module_raop_discover.html
  services.pipewire.raopOpenFirewall = true;
  hardware.pulseaudio.zeroconf.discovery.enable = true;
  services.pipewire.extraConfig.pipewire."zz_raop-discover" = {
    "context.modules" = [
      {
        name = "libpipewire-module-raop-discover";
        #args = {
        #  #"roap.discover-local" = true;
        #  #"raop.discover-local" = true;
        #  "stream.rules" = [
        #    { matches = [
        #        { raop.ip = "~.*";
        #        }
        #      ];
        #      actions = {
        #        create-stream = {
        #          stream.props = {};
        #        };
        #      };
        #    }
        #  ];
        #};
      }
    ];
  };
}
