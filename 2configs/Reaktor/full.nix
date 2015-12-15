_:
{
  # implementation of the complete Reaktor bot
  imports = [
      #./stockholmLentil.nix
      ./simpleExtend.nix
      ./random-emoji.nix
      ./titlebot.nix
      ./shack-correct.nix
      ./sed-plugin.nix
  ];
  krebs.Reaktor.nickname = "Reaktor|bot";
  krebs.Reaktor.enable = true;

  krebs.Reaktor.extraEnviron = {
    REAKTOR_CHANNELS = "#krebs,#binaergewitter,#shackspace";
  };
}
