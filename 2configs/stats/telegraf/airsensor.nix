{ pkgs, ...}:

{
  services.telegraf.extraConfig.inputs.exec = [
    {
      commands = [ "${pkgs.airsensor-py}/bin/airsensor-py"];
      timeout = "10s";
      data_format = "value";
      data_type = "integer";
      name_override = "airquality";
      interval = "10s";
      tags.unit="VOC";
    }
  ];
}
