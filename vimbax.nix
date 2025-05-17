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
  lib 
}:

let
  system = stdenv.hostPlatform.system;

  urlSuffix = 
    if system == "x86_64-linux" then "Linux64"
    else if system == "aarch64-linux" then "Linux_ARM64"
    else abort "Unsupported system ${system}";

  checksums = {
    x86_64-linux = "sha256-7Y7weRdkpY0DmDtzXFLhszZ2R93tYFgkPqHSh/+3VGY=";
    aarch64-linux = "";
  };
  
  vimbaXLibLocation = "$out/lib";
  
  binaries = {
   ListCameras_VmbC = "vimbax-list-cameras";
   ListFeatures_VmbC = "vimbax-list-features";
   VimbaXViewer = "VimbaXViewer";
   VimbaXFirmwareUpdater = "VimbaXFirmwareUpdater";
  };
in

stdenv.mkDerivation rec {
  pname = "vimba-x";
  version = "2025-1";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  src = fetchzip {
    url = "https://downloads.alliedvision.com/VimbaX/VimbaX_Setup-${version}-${urlSuffix}.tar.gz";
    sha256 = checksums.${system};
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
    mkdir -p ${vimbaXLibLocation}/bin
    addAutoPatchelfSearchPath ${vimbaXLibLocation}/bin/
    cp -r $src/* ${vimbaXLibLocation}/ 
    runHook postInstall
  '';

  # No build phase - vendor libraries (ew)
  installPhase = lib.mapAttrsToList (name: value: ''
    makeWrapper ${vimbaXLibLocation}/bin/${name} $out/bin/${value} --set GENICAM_GENTL64_PATH "${vimbaXLibLocation}/cti"
  '') binaries;
}
