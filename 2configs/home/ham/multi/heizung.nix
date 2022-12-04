{
  services.home-assistant.config =
    {
      # 18 Grad
      script.alle_heizungen_aus.sequence = [{
        service = "climate.set_temperature";
        target.entity_id = [ "climate.wohnzimmer_heizung" ];
        data.temperature = "18.0";
      }];
    };
}
