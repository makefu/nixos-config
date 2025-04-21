{
  services.grocy = {
    enable = true;
    hostName = "shop.euer.krebsco.de";
    nginx.enableSSL = true;
    settings = {
      currency = "EUR";
      culture = "de";
      calendar.showWeekNumber = true;
      calendar.firstDayOfWeek = 1;
    };
  };
}
