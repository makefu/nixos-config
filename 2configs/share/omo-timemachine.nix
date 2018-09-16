{ pkgs, ... }:
{
  services.samba = {
    # support for timemachine in git
    package = pkgs.sambaFull;
    shares = {
      time_machine = {
        path = "/media/crypt3/backup/time_machine";
        "valid users" = "misa";
        public = "no";
        writeable = "yes";
        "force user" = "misa";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
}
