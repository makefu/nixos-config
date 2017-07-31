{pkgs, ...}:
let
  itf = "enp0s25";
in {
  systemd.services.rst-issue = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      d=/var/cache/rst-issue
      mkdir -p $d
      cd $d
      ITF=${itf}
      now=$(date --rfc-3339=s | sed 's/ /T/')
      ${pkgs.tcpdump}/bin/tcpdump -i $ITF -w run-$now.pcap &
      echo "timestamp,$now" >> mtr.log
      ${pkgs.mtr}/bin/mtr -4 --tcp bsi.bund.de www.thalesgroup.com nokia.com -C --show-ips -z >> mtr.log
      kill %1
    '';
    startAt = "*:0/15"; # every 15 minutes

  };
}
