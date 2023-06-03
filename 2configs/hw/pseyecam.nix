# https://bugzilla.kernel.org/show_bug.cgi?id=198129
{
  boot.extraModprobeConfig = ''
    options snd_usb_audio ignore_ctl_error=1
  '';
}
