let
  cred = import <secrets/ham/nextcloud-calendar>;
in
{
  services.home-assistant.config.calendar =
  [
    {
      platform = "caldav";
      inherit (cred) username password;
      url = "https://o.euer.krebsco.de/remote.php/dav";
    }
  ];
}
