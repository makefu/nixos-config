{ config, lib, pkgs, ... }:
let
  seeed-voicecard = (pkgs.callPackage ../../5pkgs/seeed-voicecard { kernel = config.boot.kernelPackages.kernel; });
in
{
  hardware.raspberry-pi."4".i2c1.enable = true;
  hardware.raspberry-pi."4".audio.enable = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree.filter = lib.mkForce "bcm2711-rpi-4-b.dtb";

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    alsaUtils
    i2c-tools
    ponymix
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire = {
    enable = true;
    systemWide = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pipewire.config.pipewire-pulse = {
    "pulse.properties"."server.address" = [ "unix:native" "tcp:4713" ];
  };

  sound.extraConfig = ''
    pcm.!default {
        type asym
        playback.pcm "playback"
        capture.pcm "ac108"
    }

    pcm.ac108 {
        type plug
        slave.pcm "hw:seeed4micvoicec"
    }
  '' ;


  boot.extraModulePackages = [
    seeed-voicecard
  ];
  boot.initrd.kernelModules = [ 
    "snd-soc-seeed-voicecard" 
    "snd-soc-ac108"
    "i2c-dev" 
    #"i2c-bcm2708"
    #"snd-soc-wm8960"
  ];

  boot.loader.raspberryPi.firmwareConfig = [
    "dtparam=i2c_arm=on"
    "dtparam=i2s=on"
    "dtparam=spi=on"
    "dtparam=i2c1=on"
    # dtoverlay=seeeed-8mic-voicecard  not required because we use hardware.deviceTree
  ];
  hardware.deviceTree = {
    enable = true;
    overlays = [
      { name = "respeaker-4mic"; dtsFile = "${seeed-voicecard}/lib/dts/seeed-4mic-voicecard-overlay.dts";}
      { name = "spi"; dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "raspberrypi";
            fragment@0 {
              target = <&spi>;
              __overlay__ {
                cs-gpios = <&gpio 8 1>, <&gpio 7 1>;
                status = "okay";
                pinctrl-names = "default";
                pinctrl-0 = <&spi0_pins &spi0_cs_pins>;
                #address-cells = <1>;
                #size-cells = <0>;
                spidev@0 {
                  reg = <0>;	// CE0
                  spi-max-frequency = <500000>;
                  compatible = "spidev";
                };

                spidev@1 {
                  reg = <1>;	// CE1
                  spi-max-frequency = <500000>;
                  compatible = "spidev";
                };
              };
            };
                  fragment@1 {
              target = <&alt0>;
              __overlay__ {
                // Drop GPIO 7, SPI 8-11
                brcm,pins = <4 5>;
              };
            };

            fragment@2 {
              target = <&gpio>;
              __overlay__ {
                spi0_pins: spi0_pins {
                  brcm,pins = <9 10 11>;
                  brcm,function = <4>; // alt0
                };
                spi0_cs_pins: spi0_cs_pins {
                  brcm,pins = <8 7>;
                  brcm,function = <1>; // out
                };
              };
            };
          };
        '';}
    ];
  };
}
