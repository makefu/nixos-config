{
  services.grocy = {
    enable = true;
    hostName = "shop.euer.krebsco.de";
    nginx.enableSSL = true;
    settings = {
      curreny = "EUR";
      culture = "de";
      calendar.showWeekNumber = true;
      calendar.firstDayOfWeek = 1;
    };
  };
}
