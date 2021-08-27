let
  inherit (../lib) btn_cycle_light;
in {
  services.home-assistant.config.automation = [
    (btn_cycle_light "light.keller_osram" "keller_btn1" 128)
  ];
}
