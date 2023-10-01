let
  disko = import (builtins.fetchGit {
    url = https://cgit.lassul.us/disko/;
    rev = "9c9b62e15e4ac11d4379e66b974f1389daf939fe";
  });

  cfg = builtins.fromJSON (builtins.readFile ../../hardware/tsp-disk.json);
in ''
${disko.create cfg}
${disko.mount cfg}
''
