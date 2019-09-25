{ lib, ... }:
let
  aramark = topic: name:
  { platform = "mqtt";
    inherit name;
    state_topic = "/aramark/thales-deutschland/${topic}";
  };
  aramark_menue = menue:
  [
    (aramark "${menue}/title" menue)
    (aramark "${menue}/description" "${menue} Text")
   ((aramark "${menue}/price" "${menue} Preis") // { unit_of_measurement = "€"; })
  ];
in
{
  sensor = (aramark_menue "Menü 1")
        ++ (aramark_menue "Menü 2")
        ++ (aramark_menue "Mercato")
        ++ (aramark_menue "Aktion");
  binary_sensor =
  [
    ((aramark "pommes" "Pommes" ) // { payload_on = "True"; payload_off = "False"; })
  ];
}
