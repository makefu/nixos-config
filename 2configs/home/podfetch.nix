{ inputs, pkgs, config, ... }:
{
  imports = [
    inputs.podfetch.nixosModules.podfetch
  ];
  sops.secrets.podfetch = {
    owner = "download";
  };
  services.podfetch = {
    enable = true;
    package = inputs.podfetch.packages.${pkgs.system}.podfetchFull;
    user = "download";
    interval = "6h";
    settings = {
      notify = {
        enabled = true;
        new_episodes = true;
        errors = true;
        error_throttle_minutes = 60;
        max_episode_messages = 5;
      };
      output_dir = "/media/silent/music/kinder/podfetch";
      ads = {
        enabled = true;
        # Master switch is on; feeds are cut only when they opt in via
        # cut_ads (was.ist.was below). default_cut=false = nobody by default.
        default_cut = false;
        debug_dir = "/media/silent/music/kinder/podfetch_ads";
        engines = [
          # "silence"
          # "fingerprint"
          "asr"
          "neuralblock"
          "sponsorblock-ml"
        ];
        # 1.3.0: engine knobs live under ads.<engine>.* (engine name as in
        # `engines`); unknown keys there are config errors, so typos fail.
        asr = {
          language = "de";
          model = "base";
          model_dir = "/var/lib/podfetch/models/whisper";
        };
        # model_dir null -> weights come from the podfetchFull wrapper's
        # $PODFETCH_NEURALBLOCK_DIR (baked at build time).
        neuralblock = { };
        # model_dir null -> HF hub download into the state dir on first use.
        "sponsorblock-ml" = {
          min_probability = 0.5;
        };
      };
      feeds = [
        { name = "CheckPod"; url = "https://feeds.br.de/checkpod-der-podcast-mit-checker-tobi/feed.xml"; slug = "checkpod"; }
        { name = "Die Maus zum Hören"; url = "https://kinder.wdr.de/radio/diemaus/audio/diemaus-60/diemaus-60-106.podcast"; slug = "die.maus.zum.hoeren"; }
        { name = "Anna und die wilden Tiere"; url = "https://feeds.br.de/anna-und-die-wilden-tiere/feed.xml"; slug = "anna.und.die.wilden.tiere"; }
        { name = "Lachlabor"; url = "https://feeds.br.de/lachlabor/feed.xml"; slug = "lachlabor"; }
        { name = "Alle gegen Nico"; url = "https://feeds.br.de/alle-gegen-nico-zockt-um-die-quizkrone/feed.xml"; slug = "alle.gegen.nico"; }
        { name = "Eric erforscht..."; url = "http://feeds.libsyn.com/299396/rss"; slug = "eric.erforscht"; }
        { name = "Mikado macht Schlau"; url = "https://www.ndr.de/nachrichten/info/sendungen/mikado/podcast4472.xml"; slug = "mikado.macht.schlau"; }
        { name = "Das Geheimnis"; url = "https://feeds.br.de/do-re-mikro-die-musiksendung-fuer-kinder/feed.xml"; slug = "das.geheimnis"; }
        { name = "Welten Entdecken"; url = "https://podcast.hr.de/hr2_erzaehlpodcast_kind_2024/podcast.xml"; slug = "welten.entdecken"; }
        { name = "Professorin Domino"; url = "https://sr-mediathek.de/pcast/feeds/SR1_DO_P/feed.xml"; slug = "professorin.domino"; }
        { name = "Kakadu"; url = "https://www.kakadu.de/kakadu-104.xml"; slug = "kakadu"; }
        { name = "Was ist Was Podcast"; url = "https://feeds.megaphone.fm/KBBF5520541713"; slug = "was.ist.was"; cut_ads = true; }
      ];
    };
    settingsFile = config.sops.secrets.podfetch.path;
  };
}
