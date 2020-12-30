let
  schlafzimmer_licht = [
    "light.schlafzimmer_komode_osram"
    # "light.schlafzimmer_schrank_osram"
  ];
in {
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Schlafzimmerbeleuchtung";
      entities = schlafzimmer_licht;
    }
  ];
}
