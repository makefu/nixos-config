{pkgs, buil, config, ...}:
let
  log-server = config.makefu.log-server;
  log-port = 9200;
in {
  services.journalbeat = {
    enable = true;
    # TODO: filter for certain journal fields, not all
    extraConfig = ''
      journalbeat:
        name: logs-${config.krebs.build.host.name}
        seek_position: cursor
        cursor_seek_fallback: tail
        write_cursor_state: true
        cursor_flush_period: 5s
        clean_field_names: true
        convert_to_numbers: false
        move_metadata_to_field: journal
        default_type: journal
      output.elasticsearch:
        enabled: true
        hosts: ["${log-server}:${builtins.toString log-port}"]
        template.enabled: false
      #output.console:
      #  enabled: true
      logging.level: info
      logging.to_syslog: true
      logging.selectors: ["*"]

    '';
  };
}
