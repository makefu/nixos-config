{ pkgs, ... }:
let
  pkg = pkgs.writeDash "reset_usb_controllers.sh" ''
    ${pkgs.pciutils}/bin/lspci -D | grep -e 'USB controller:.*xHCI Controller' \
      | awk '{print $1}') \
      | while read usb_controller_address; do
        echo "$usb_controller_address" | sudo tee '/sys/bus/pci/drivers/xhci_hcd/unbind';
        sleep 1;
        echo "$usb_controller_address" | sudo tee '/sys/bus/pci/drivers/xhci_hcd/bind';
    done
  '';
in
  {
    services.udev.extraRules = [
      ''ACTION=="offline", SUBSYSTEM=="usb", KERNEL=="usb2",ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", RUN+="${reset_script}"''
    ];
}
