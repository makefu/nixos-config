{ pkgs, lib, ... }:
{
  # current issues:
  #  1. for pressing insert hold shift+fn+Fin

  # scroll by holding middle mouse
  #services.xserver.displayManager.sessionCommands =''
  #    xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation" 8 1
  #    xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Button" 8 2
  #    xinput set-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
  #    # configure timeout of pressing and holding middle button
  #    # xinput set-int-prop "ETPS/2 Elantech TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  #    xinput disable 'ETPS/2 Elantech Touchpad'
  #'';

  services.xserver.libinput.enable = true;
  boot.kernelParams = [
    #"psmouse.proto=imps"
    #"psmouse.proto=bare"
    #"psmouse.resetafter=0"
    "psmouse.synaptics_intertouch=1" # echo 1 > /sys/devices/platform/i8042/serio1/reg_07
  ];

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -A 10"; } # fn - F5
      { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -U 10"; } # fn - F6
      # fn - 4 => suspend
      # fn - d => lcdshadow
      #{ keys = [ 227 ]; events = [ "key" ]; command = builtins.toString ( # fn - F7
      #  pkgs.writers.writeDash "toggle_touchpad" ''
      #    PATH=${lib.makeBinPath [ pkgs.xorg.xinput pkgs.gnugrep ]}
      #    DISPLAY=:0
      #    export DISPLAY PATH

      #    device=$(xinput list --name-only | grep Touchpad)
      #    if [ "$(xinput list-props "$device" | grep -P ".*Device Enabled.*\K.(?=$)" -o)" -eq 1 ];then
      #        xinput disable "$device"
      #    else
      #        xinput enable "$device"
      #    fi
      #  '');
      #}
    ];
  };
}
