{ pkgs }:

# OpenVINO backend for llama.cpp
#
# Known issues:
# - CPY operation fails on Intel GPU (e.g., 1340p with Iris Xe) with error:
#   "pre-allocated tensor (cache_r_l0 (view) (copy of )) in a buffer (OPENVINO0) that cannot run the operation (CPY)"
#   Works fine on CPU backend.
#
# Upstream references:
# - nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/llama-cpp.nix
# - nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ll/llama-cpp/package.nix
# - llama.cpp: https://github.com/ggml-org/llama.cpp/blob/master/flake.nix
# - llama.cpp PR (OpenVINO backend): https://github.com/ggml-org/llama.cpp/pull/15307
# - Watch for issues: https://github.com/ggml-org/llama.cpp/pulls?q=openvino
# - TBB issue: https://github.com/ggml-org/llama.cpp/pull/20566
#
let
  llama-cpp-src = pkgs.fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    rev = "d23355afc319f598d0e588a2d16a4da82e14ff41";
    sha256 = "sha256-akuU5NqC7ZeS7GJraCKJ+SyaZyx3mYZsMqEX8K8isBU=";
  };
  tbbPath = "${pkgs.tbb.dev}/lib/cmake/TBB";
in

pkgs.llama-cpp.overrideAttrs (oldAttrs: {
  pname = "llama-cpp-openvino";

  src = llama-cpp-src;

  npmDepsHash = "sha256-5ZswgZFLeI32/xQZqCTTFbCzleDqr5AotjFg/5rNn1M=";

  postPatch = ''
    sed -i "s|include.*3rdparty/tbb.*TBBConfig.cmake.*|find_package(TBB REQUIRED)\ninclude(${tbbPath}/TBBConfig.cmake)|" ggml/src/ggml-openvino/CMakeLists.txt
  '';

  buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
    pkgs.openvino
    pkgs.ocl-icd
    pkgs.opencl-clhpp
    pkgs.tbb
  ];

  cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
    "-DGGML_OPENVINO=ON"
    "-DOpenVINO_DIR=${pkgs.openvino}/runtime/cmake"
    "-DTBB_DIR=${tbbPath}"
    "-DCMAKE_SKIP_BUILD_RPATH=OFF"
  ];

  postInstall = ''
    ln -sf $out/bin/llama-cli $out/bin/llama

    mkdir -p $out/include
    cp $src/include/llama.h $out/include/

    for f in $out/bin/llama-*; do
      patchelf --add-rpath "${pkgs.openvino}/runtime/lib/intel64" "$f" 2>/dev/null || true
    done

    for f in $out/lib/lib*.so*; do
      patchelf --add-rpath "${pkgs.openvino}/runtime/lib/intel64" "$f" 2>/dev/null || true
    done
  '';

  meta = (oldAttrs.meta or { }) // {
    description = "Inference of LLaMA model in pure C/C++ with OpenVINO backend";
  };
})
