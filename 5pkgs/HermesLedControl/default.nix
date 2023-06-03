{ lib, pkgs, python3Packages, makeWrapper, ... }:

# How to use:
# create configuration configuration.yml:
#   engine: "rhasspy"
#   pathToConfig: "/var/lib/rhasspy/de/profile.json"
#   hardware: "respeaker4MicArray"
#   pattern: "fake-name"
#   enableDoA: false
# and run HermesLedControl --hermesLedControlConfig path-to-config.yml

# all available config options can be see in:
#   result/result/lib/HermesLedControl/models/Configuration.py


with python3Packages; buildPythonApplication rec {
  name = "HermesLedControl-${version}";
  format = "other";
  version = "3.0.4";

  src = pkgs.fetchFromGitHub {
    owner = "project-alice-assistant";
    repo = "HermesLedControl";
    rev = "v${version}";
    hash = "sha256-fVbTQPSo3fNjLb8PDDDqhMC9Hez01rTH46cKz/mfwoU=";
  };

  patches = [
    ./remove-logger.patch
  ];

  execWrapper = ''
    #!/bin/sh
    cd $out/lib/HermesLedControl && \
      PYTHONPATH="${makePythonPath propagatedBuildInputs}" exec \
        ${python}/bin/python  "$out/lib/HermesLedControl/main.py" "$@"
  '';

  installPhase = ''
    install -d "$out/lib/"
    install -d "$out/bin"
    cp -r . $out/lib/HermesLedControl

    echo "${execWrapper}" > HermesLedControl
    install -Dm755 HermesLedControl $out/bin/HermesLedControl

  '';

  propagatedBuildInputs = [
    spidev gpiozero rpi-gpio pyyaml paho-mqtt types-pyyaml makeWrapper
  ];

  meta = {
    homepage = "https://github.com/project-alice-assistant/HermesLedControl";
    description = "Provides an easy way to control your leds in an Hermes environment";
    license = lib.licenses.gpl3;
  };
}
