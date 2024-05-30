{
  services.pipewire.extraConfig.pipewire."91-combine-bluetooth-inputs" = {
    "context.modules" = [
      {
        name = "libpipewire-module-combine-sink";
        args = {
          "combine.mode" = "sink";
          "node.name" = "combined_output";
          "node.description" = "Combined Output";
          "combine.latency-compensate" = false;
          "filter.media.class" = "Audio/Sink";
          "filter.media.role" = "music";
          "filter.bluez.transport" = "a2dp_sink";
        };
      }
    ];
  };
}
