let
  cred = import <secrets/ham/nextcloud-calendar>;
in
{
  platform = "caldav";
  inherit (cred) username password;
  url = "https://o.euer.krebsco.de/remote.php/dav";
}
