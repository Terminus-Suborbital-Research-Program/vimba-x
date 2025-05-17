{
  stdenv,
  fetchzip,
  makeWrapper,
  autoPatchelfHook,
  libgcc,
  waylandpp,
  xorg,
  libxcb,
  fontconfig,
  libxkbcommon,
  libGL,
  xcbutilrenderutil,
}:

stdenv.mkDerivation rec {
  pname = "vimba-x";
  version = "2025-1";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  src = fetchzip {
    url = "https://downloads.alliedvision.com/VimbaX/VimbaX_Setup-${version}-Linux64.tar.gz";
    sha256 = "sha256-7Y7weRdkpY0DmDtzXFLhszZ2R93tYFgkPqHSh/+3VGY=";
  };


  buildInputs = [
    stdenv.cc.cc.lib
    libgcc
    waylandpp.lib
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.libXinerama
    xorg.xcbutilwm
    libxcb
    fontconfig.lib
    libxkbcommon
    libGL
    xcbutilrenderutil
  ];
  
  preBuild = ''
    addAutoPatchelfSearchPath $src/bin/
  '';

  # No build phase - vendor libraries (ew)
  buildPhase = ''
    mkdir -p $out
    cp -r $src/* $out
    runHook postInstall
  '';

  # Install - create links
  installPhase = ''
    mkdir -p $out/final
    makeWrapper $out/bin/ListCameras_VmbC $out/final/list --set GENICAM_GENTL64_PATH "$out/cti/"
  '';
}
