let
  inherit (import <secrets/signal/messenger.nix>) number home felix;
in {
  services.home-assistant.config.notify = [
    {
      name = "signal_home";
      platform = "signal_messenger";
      url = "http://127.0.0.1:8631";
      inherit number ;
      recipients = [ home ];
    }
    {
      name = "signal_felix";
      platform = "signal_messenger";
      url = "http://127.0.0.1:8631";
      inherit number;
      recipients = [ felix ];
    }
  ];
}
