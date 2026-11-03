{...}:
{
  services.telegraf = {
    enable = true;
    extraConfig = {
      global_tags = {};
      agent = {
        interval = "10s";
        debug = false;
        hostname = "victorianix.jit-creatives.de";
        round_interval = true;
        flush_interval = "10s";
        flush_jitter = "0s";
        collection_jitter = "0s";
        metric_batch_size = 1000;
        metric_buffer_limit = 10000;
        quiet = false;
        logfile = "";
        omit_hostname = false;
      };
      outputs = {
        influxdb = [{
          urls = [ "http://potsdam.jit-creatives.de:8086" ];
          database = "telegraf";
          timeout = "5s";
        }];
      };
      inputs = {
        cpu = [{ percpu = true; }];
        disk = [{}];
        diskio = [{}];
        mem = [{}];
        net = [{}];
        system = [{}];
        swap = [{}];
        netstat = [{ interval = "60s"; }];
        processes = [{ interval = "60s"; }];
        kernel = [{ interval = "60s"; }];
      };
    };
  };
}
