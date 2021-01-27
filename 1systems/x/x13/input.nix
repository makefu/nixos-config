{
  # current issues:
  #  1. for pressing insert hold shift+fn+Fin

  # scroll by holding middle mouse
  services.xserver.displayManager.sessionCommands =''
      xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation" 8 1
      xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Button" 8 2
      xinput set-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
      # configure timeout of pressing and holding middle button
      # xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  '';
}
