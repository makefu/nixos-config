# Python packages for the NeuTTS German TTS stack that are not (yet) in
# nixpkgs. Everything else (torch, transformers, llama-cpp-python, phonemizer,
# librosa, soundfile, torchao, torchtune, local-attention, einx, ...) is reused
# straight from nixpkgs — only these three thin wrappers are missing upstream.
#
# Consumed from 5pkgs/default.nix as a pythonPackagesExtensions entry:
#   pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
#     (import ./neutts/python-packages.nix pkgs)
#   ];
# `pkgs` is threaded in so we can reach autoPatchelfHook / stdenv for the
# prebuilt neutts wheel (it bundles libespeak-ng.so).
pkgs:
pyfinal: pyprev: {

  # Pure-python (torch + einops + einx). neucodec pins this exact version.
  vector-quantize-pytorch = pyfinal.buildPythonPackage rec {
    pname = "vector-quantize-pytorch";
    version = "1.17.8";
    pyproject = true;
    src = pyfinal.fetchPypi {
      pname = "vector_quantize_pytorch";
      inherit version;
      sha256 = "3b9b9514dcdce7af122b7e8abae1a01b4050c3446b78b4b8a07da74f0008d3ea";
    };
    build-system = [ pyfinal.hatchling ];
    dependencies = with pyfinal; [ torch einops einx ];
    doCheck = false;
    pythonImportsCheck = [ "vector_quantize_pytorch" ];
  };

  # Neural audio codec used by NeuTTS to decode LM tokens -> 24 kHz waveform.
  neucodec = pyfinal.buildPythonPackage rec {
    pname = "neucodec";
    version = "0.0.6";
    pyproject = true;
    src = pyfinal.fetchPypi {
      inherit pname version;
      sha256 = "9a19f107bf224a1c858967ccaace38fe1efbc328ca78c8f792b8dfca9cd993e6";
    };
    build-system = [ pyfinal.poetry-core ];
    dependencies = with pyfinal; [
      torch torchaudio torchao torchtune
      vector-quantize-pytorch
      transformers local-attention numpy huggingface-hub safetensors
    ];
    # nixpkgs ships newer torch/transformers/numpy than the conservative pins.
    pythonRelaxDeps = [
      "transformers" "numpy" "torch" "torchao" "torchtune" "torchaudio"
      "vector-quantize-pytorch"
    ];
    doCheck = false;
    pythonImportsCheck = [ "neucodec" ];
  };

  # NeuTTS itself. Only ships platform wheels (the sdist builds espeak-ng via
  # CMake). The cp313 manylinux wheel is pure-python plus a bundled
  # libespeak-ng.so + espeak-ng-data, so it is self-contained for phonemization
  # once autopatchelf fixes the bundled .so. x2 is x86_64 / py3.13.
  #
  # resemble-perth (audio watermarker) is intentionally dropped: NeuTTS wraps
  # its import in try/except and degrades to unwatermarked audio, and packaging
  # perth would drag in matplotlib/pydub/pyrubberband for no functional gain.
  neutts = pyfinal.buildPythonPackage rec {
    pname = "neutts";
    version = "1.2.1";
    format = "wheel";
    src = pyfinal.fetchPypi {
      inherit pname version format;
      dist = "cp313";
      python = "cp313";
      abi = "cp313";
      platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
      sha256 = "b058e2b5efc7e9687de6251639d32cb4883b67c1e908c6ec7b573ffc39b5f432";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    dependencies = with pyfinal; [
      librosa neucodec numpy phonemizer soundfile torch transformers
      llama-cpp-python
    ];
    pythonRemoveDeps = [ "resemble-perth" ];
    pythonRelaxDeps = [ "numpy" "transformers" ];
    dontStrip = true;
    pythonImportsCheck = [ "neutts" "neuttsair" ];
  };

}
