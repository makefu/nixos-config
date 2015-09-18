{ stdenv,config, lib, pkgs, ... }:

with pkgs;
let
  pypkgs = pkgs.python3Packages;
  titlebot_cmds =  pypkgs.buildPythonPackage {
    name = "titlebot_cmds";
    propagatedBuildInputs =  with pypkgs; [ setuptools ];
    src = fetchurl {
      # https://github.com/makefu/reaktor-titlebot tag 2.1.0
      url = "https://github.com/makefu/reaktor-titlebot/archive/2.1.0.tar.gz";
      sha256 = "0wvf09wmk8b52f9j65qrw81nwrhs9pfhijwrlkzp5l7l2q8cjkp6";
      };
    };
  pub_cmds = ["up" "help" "list" "top" "highest" "undo" ];
  priv_cmds = [ "clear" ];
in {
  # TODO: write identify file in
  #     {config.users.extraUsers.Reaktor.home}/state/admin.lst
  krebs.Reaktor.extraConfig = ''
  def titlebot_cmd(cmd):
    return {
      'capname': cmd,
      'env': {
        'TITLEDB':
          '${config.users.extraUsers.Reaktor.home}/suggestions.json'
        },
      'pattern': '^\\.' + cmd + '\\s*(?:\\s+(?P<args>.*))?$$',
      'argv': [ '${titlebot_cmds}/bin/' + cmd ] }
  # TODO: for each element in ${titlebot_cmds}/bin/*
  public_commands.insert(0,titlebot_cmd('up'))
  public_commands.insert(0,titlebot_cmd('help'))
  public_commands.insert(0,titlebot_cmd('list'))
  public_commands.insert(0,titlebot_cmd('top'))
  public_commands.insert(0,titlebot_cmd('new'))
  commands.insert(0,titlebot_cmd('clear'))
  '';
}
