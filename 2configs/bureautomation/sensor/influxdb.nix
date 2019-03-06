[
  #{ platform = "influxdb";
  #  queries = [
  #    { name = "mean value of feinstaub P1";
  #      where = '' "node" = 'esp8266-1355142' '';
  #      measurement = "feinstaub";
  #      database = "telegraf";
  #      field = "P1";
  #    }
  #    { name = "mean value of feinstaub P2";
  #      where = '' "node" = 'esp8266-1355142' '';
  #      measurement = "feinstaub";
  #      database = "telegraf";
  #      field = "P2";
  #    }
  #  ];
  #}
]
