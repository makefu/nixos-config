
let
  cam = name: still_image_url:
  {
    inherit name still_image_url;
    platform = "generic";
  };
in [
  ( cam "Max-Eyth-See" https://www.wav-stuttgart.de/webcam/_/webcam1.jpg  )
  ( cam "Wilhelma" http://webcam.wilhelma.de/webcam02/webcam02.jpg )
  ( cam "Wilhelma" http://webcam.wilhelma.de/webcam02/webcam02.jpg )
]
