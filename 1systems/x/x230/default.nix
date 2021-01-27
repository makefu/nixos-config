{
  imports = [
     <stockholm/makefu/2configs/hw/tp-x230.nix> # + bluetooth
     <stockholm/makefu/2configs/fs/sda-crypto-root-home.nix>

    <stockholm/makefu/2configs/hw/tpm.nix>
    <stockholm/makefu/2configs/hw/ssd.nix>

     # hard dependency because otherwise the device will not be unlocked
     {
      boot.initrd.luks.devices.luksroot =
      {
          device = "/dev/sda2";
          allowDiscards = true;
      };
     }
     { makefu.server.primary-itf = "wlp3s0"; }
  ];
}
