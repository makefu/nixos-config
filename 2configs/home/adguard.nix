{config, ... }:
let
    itf = config.makefu.server.primary-itf;
    host = "192.168.111.11";
    port = 3688;
in {
    services.adguardhome = {
        enable = true;
        inherit port;
        mutableSettings = true;
        settings = {
          http = {
            # You can select any ip and port, just make sure to open firewalls where needed
            address = "0.0.0.0:${toString port}";
          };
          dns = {
              bind_hosts = [ host ];
            upstream_dns = [
              # Example config with quad9

              #"9.9.9.9#dns.quad9.net"
              #"149.112.112.112#dns.quad9.net"
              #"149.112.112.112"
              #"9.9.9.9"

              #"1.1.1.1"
              "192.168.111.5" # to resolve .lan domains, configured in openwrt to use 9.9.9.9
            ];
          };
          filtering = {
            protection_enabled = true;
            filtering_enabled = true;

            parental_enabled = false;  # Parental control-based DNS requests filtering.
            safe_search = {
              enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
            };
          };
          # The following notation uses map
          # to not have to manually create {enabled = true; url = "";} for every filter
          # This is, however, fully optional
          filters = map(url: { enabled = true; url = url; }) [
              "https://easylist.to/easylist/easylist.txt" # easylist germany
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_6.txt"  # Dandelion Sprout's Game Console Adblock List
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_60.txt"  # HaGeZi's Xiaomi Tracker Blocklist
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
            "https://filters.adtidy.org/extension/ublock/filters/11.txt" # adtidy android
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt" # adguard DNS
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt" # peter Lowes Blocklist
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt" # HaGeZi Pro++
          ];
        };
    };
    networking.firewall = {
        interfaces."${itf}" = {
            allowedTCPPorts = [ port ];
            allowedUDPPorts = [ 53 ];
        };
    };
}
