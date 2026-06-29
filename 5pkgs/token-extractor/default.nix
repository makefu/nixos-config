{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
buildPythonApplication rec {
  pname = "token-extractor";
  version = "unstable-2024-c4db715";
  format = "other";

  src = fetchFromGitHub {
    owner = "PiotrMachowski";
    repo = "Xiaomi-cloud-tokens-extractor";
    rev = "c4db715dace9806e905153c2977608873e8ab7c9";
    sha256 = "0n6xm000dwk0njidnswm5i7h09z6m95bdj05ignhdlnwlm0yd4bk";
  };

  propagatedBuildInputs = [
    requests
    pycryptodome
    pillow
    colorama
    charset-normalizer
  ];

  installPhase = ''
    runHook preInstall
    install -Dm644 token_extractor.py $out/share/token-extractor/token_extractor.py
    mkdir -p $out/bin
    makeWrapper ${pkgs.python3.interpreter} $out/bin/token-extractor \
      --add-flags "$out/share/token-extractor/token_extractor.py" \
      --prefix PYTHONPATH : "$PYTHONPATH"
    runHook postInstall
  '';

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Retrieve tokens and BLE keys for Xiaomi cloud devices";
    homepage = "https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor";
    license = licenses.mit;
    mainProgram = "token-extractor";
  };
}
