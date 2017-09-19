{ pkgs, ...}:
let
  pkg = with pkgs.python3Packages;buildPythonPackage rec {
    rev = "be31da7";
    name = "europastats-${rev}";
    propagatedBuildInputs = [
      requests2
      docopt
    ];
    src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/europastats";
      inherit rev;
      sha256 = "0qj18vgj9nm6aisyqhk3iz3rf8xp7mn5jc6sfylcaw588a9sjfvc";
    };
  };
in {
  services.telegraf.extraConfig.inputs.exec = [
    {
      commands = [ "${pkg}/bin/europa-attractions"];
      timeout = "1m";
      data_format = "json";
      name_override = "europawaiting";
      interval = "1m";
      tag_keys = [
        "status"
        "type"
        "name"
      ];
    }
    {
      commands = [ "${pkg}/bin/europa-weather"];
      timeout = "20s";
      data_format = "json";
      name_override = "europaweather";
      interval = "10m";
      tag_keys = [
        "type"
        "name"
        "offset"
      ];
    }
  ];
}
