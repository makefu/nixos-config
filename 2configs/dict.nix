{ pkgs, ... }:
{
  services.dictd.enable = true;
  services.dictd.DBs = with pkgs.dictdDBs; [ wiktionary wordnet deu2eng eng2deu ];
}
