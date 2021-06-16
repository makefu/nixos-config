{ lib, fetchFromGitHub, buildGoModule, ... }:
  buildGoModule rec {
  pname = "otpauth";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "dim13";
    repo = "otpauth";
    rev = "v${version}";
    sha256 = "1q6byb87cyvm4prildfcr8qc283ikvz5zazm92jk19qhav6ywj65";
  };

  vendorSha256 = "0lhxc855lr0mzq35i0s2xkcd4qa74yks6ypi80ij9ia0x1hdf1dq";

  runVend = false;

  meta = with lib; {
    description = "Google Authenticator migration decoder";
    homepage = "https://github.com/dim13/otpauth";
    license = licenses.isc;
    maintainers = with maintainers; [ makefu ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
