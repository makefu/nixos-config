_:

{
  imports = [ ../3modules ];
  makefu.umts = {
    enable = true;
    modem-device = "/dev/serial/by-id/usb-Lenovo_H5321_gw_2D5A51BA0D3C3A90-if01";
  };
}
