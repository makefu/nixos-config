
let
  cam = name: still_image_url:
  {
    inherit name still_image_url;
    platform = "generic";
  };
in [
  ( cam "Max-Eyth-See" https://www.wav-stuttgart.de/webcam/_/webcam1.jpg  )
  ( cam "Wilhelma" http://webcam.wilhelma.de/webcam02/webcam02.jpg )
  ( cam "Marktplatz" https://webcam.stuttgart.de/wcam007/current.jpg )
  ( cam "Schoch Areal" https://webcam.stuttgart.de/wcam004/current.jpg )
  ( cam "Leuze" https://webcam.stuttgart.de/wcam005/current.jpg )
  ( cam "Straße Wilhelma" https://webcam.stuttgart.de/wcam006/current.jpg )
  ( cam "Fernsehturm 1" http://webcam.fernsehturmstuttgart.com/current.jpg )
  ( cam "Fernsehturm 2" http://webcam.fernsehturmstuttgart.com/current2.jpg )
  ( cam "Feuerbach Lemberg" http://www.regio7.de/handy/current.jpg )
  ( cam "Flughafen Stuttgart 1" http://webcam.flughafen-stuttgart.de/Flughafen_Stuttgart_Webcam2.jpg )
  ( cam "Flughafen Stuttgart 2" http://webcam.flughafen-stuttgart.de/Flughafen_Stuttgart_Webcam5.jpg )
  ( cam "Flughafen Stuttgart 3" http://webcam.flughafen-stuttgart.de/Flughafen_Stuttgart_Webcam7.jpg )
  ( cam "S21 1" http://webcam-bahnprojekt-stuttgart-ulm.de/S21-Turm-03/s21-turm03.jpg )
  ( cam "S21 2" http://webcam-bahnprojekt-stuttgart-ulm.de/S21-Turm-02/s21-turm-02.jpg )
  ( cam "S21 3" http://webcam-bahnprojekt-stuttgart-ulm.de/S21-Turm-01/s21-turm-01.jpg )
  ( cam "S21 4" http://webcam-bahnprojekt-stuttgart-ulm.de/S21-Jaegerstrasse-Nordkopf/s21-jaegerstrassse-nordkopf.jpg )
  ( cam "S21 5" http://webcam-bahnprojekt-stuttgart-ulm.de/S21-Bahndirektion-Nord/S21-Bundesbahndirektion-Nord.jpg )
]
