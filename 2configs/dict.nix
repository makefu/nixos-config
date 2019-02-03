{ pkgs, ... }:
{
  environment.shellAliases.dict = "dict -h 127.0.0.1";
  services.dictd.enable = true;
  services.dictd.DBs = with pkgs.dictdDBs; [ wiktionary wordnet deu2eng eng2deu ];
}
