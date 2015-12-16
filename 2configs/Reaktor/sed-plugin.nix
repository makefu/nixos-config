{ config, lib, pkgs, ... }:

with pkgs;
let
  script =  ./sed-plugin.py;
in {
  #TODO: this will eat up the last regex, fix Reaktor
  krebs.Reaktor.extraConfig = ''
  public_commands.append({
    'capname' : "sed-plugin",
    # only support s///gi
    'pattern' : '^(?P<args>.*)$$',
    'argv'    : ["${pkgs.python3}/bin/python3","${script}"],
    'env'     : { 'state_dir' : workdir,
                  'PATH':'${lib.makeSearchPath "bin" [pkgs.gnused]}' }})
  '';
}

