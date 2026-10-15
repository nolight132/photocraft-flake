{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dbus,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  vulkan-loader,
  wayland,
}:

let
  sources = lib.importJSON ./sources.json;

  # The release names its tarballs by CPU, not by Nix system.
  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "aarch64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "photocraft: unsupported system ${stdenv.hostPlatform.system}");

  # The binaries link only libc and libgcc. Everything else they dlopen at startup, so
  # autoPatchelf cannot see it and the wrapper puts it on LD_LIBRARY_PATH instead.
  runtimeLibs = [
    dbus
    libGL
    libx11
    libxcb
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "photocraft";
  inherit (sources) version;

  src = fetchurl {
    url = "https://github.com/storytold/photocraft/releases/download/v${sources.version}/photocraft-${sources.version}-linux-${arch}.tar.gz";
    hash = sources.hashes.${arch};
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin share $out/
    runHook postInstall
  '';

  postFixup = ''
    for bin in photocraft photocraft-cli; do
      wrapProgram $out/bin/$bin --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
    done
  '';

  meta = {
    description = "Photo editor written from scratch in Rust";
    homepage = "https://github.com/storytold/photocraft";
    changelog = "https://github.com/storytold/photocraft/releases/tag/v${sources.version}";
    license = with lib.licenses; [
      asl20
      mit
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "photocraft";
  };
}
