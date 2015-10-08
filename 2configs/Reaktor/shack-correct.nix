{ config, lib, pkgs, ... }:

with pkgs;
let
  script = pkgs.substituteAll ( {
    name="shack-correct";
    isExecutable=true;
    dir = "";
    src = ./shack-correct.sh;
    });
in {
  krebs.Reaktor.extraConfig = ''
  public_commands.insert(0,{
    'capname' : "shack-correct",
    'pattern' : '^(?P<args>.*Shack.*)$$',
    'argv'    : ["${script}"],
    'env'     : {  }})
  '';
}

