{ pkgs, lib, ... }:
with lib;
let
  region = "112";
  types = [
      "Erle"
      "Beifuss"
      "Ambrosia"
      "Birke"
      "Esche"
      "Hasel"
      "Graeser"
      "Roggen"
    ];
    gen_tomorrow_sensor = type: {
      name = "dwd_pollenbelastung_${toLower type}_tomorrow";
      value = {
       icon_template = "mdi:grass";
       friendly_name = "${type} Morgen";
       value_template = "{{ state_attr('sensor.dwd_pollenbelastung_${toLower type}', 'tomorrow') }}";
      };
    };
    gen_sensor = type: {
      name = "dwd_pollenbelastung_${toLower type}";
      value = {
        icon_template = "mdi:tree-outline";
        friendly_name = type;
        value_template = ''
         {% set dwd_state = state_attr('sensor.dwd_pollenbelastung_stuttgart', '${type}')['today'] %}
         {% if dwd_state == "3" %}6{% elif dwd_state == "2-3"%}5{% elif dwd_state == "2"%}4{% elif dwd_state == "1-2"%}3{% elif dwd_state == "1"%}2{% elif dwd_state == "0-1"%}1{% else %}0{% endif %}
        '';
        attribute_templates.today = ''
           {% set dwd_state = state_attr('sensor.dwd_pollenbelastung_stuttgart', '${type}')['today'] %}
           {% if dwd_state == "3" %}6{% elif dwd_state == "2-3"%}5{% elif dwd_state == "2"%}4{% elif dwd_state == "1-2"%}3{% elif dwd_state == "1"%}2{% elif dwd_state == "0-1"%}1{% else %}0{% endif %}
        '';
        attribute_templates.tomorrow = ''
           {% set dwd_state = state_attr('sensor.dwd_pollenbelastung_stuttgart', '${type}')['tomorrow'] %}
           {% if dwd_state == "3" %}6{% elif dwd_state == "2-3"%}5{% elif dwd_state == "2"%}4{% elif dwd_state == "1-2"%}3{% elif dwd_state == "1"%}2{% elif dwd_state == "0-1"%}1{% else %}0{% endif %}
        '';
        # -1 == unknown
        #attribute_templates.dayafter = ''
        #   {% set dwd_state = state_attr('sensor.dwd_pollenbelastung', '${type}')['dayafter_to'] %}
        #   {% if dwd_state == "3" %}6{% elif dwd_state == "2-3"%}5{% elif dwd_state == "2"%}4{% elif dwd_state == "1-2"%}3{% elif dwd_state == "1"%}2{% elif dwd_state == "0-1"%}1{% elif dwd_state == "-1"%}-1{% else %}0{% endif %}
        #'';
      };
    };
in
  {
  services.home-assistant.config.sensor = [
  { 
    platform = "rest";
    scan_interval = 3600;
    name = "DWD Pollenbelastung Stuttgart";
    resource = "https://opendata.dwd.de/climate_environment/health/alerts/s31fg.json";
    json_attributes_path = "$..content[?(@.partregion_id==${region})].Pollen";
    json_attributes =  types;
    value_template = "{{ value_json.last_update }}";
  }
  {
    platform = "template";
    sensors = (listToAttrs (map gen_sensor types)) //
              (listToAttrs (map gen_tomorrow_sensor types)) ;
  }
  ];
}
