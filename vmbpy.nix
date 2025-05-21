{ lib, stdenv, autoPatchelfHook, python311, python311Packages, vimbax }:

let
  archSuffix = if stdenv.hostPlatform.system == "x86_64-linux" then
    "linux_x86_64"
  else if stdenv.hostPlatform.system == "aarch64-linux" then
    "linux_aarch64"
  else
    throw "Unsupported System!";

  version = "1.1.0";

  wheelName = "vmbpy-${version}-py3-none-${archSuffix}.whl";

  pythonDeps = with python311Packages; [ numpy opencv-python ];
in python311Packages.buildPythonPackage {
  pname = "vmbpy";
  inherit version;
  format = "wheel";

  src = "${vimbax}/lib/api/python/${wheelName}";

  preFixup = ''
    target_dir="$out/${python311.sitePackages}/vmbpy/c_binding/lib"
    mkdir -p "$target_dir"
    rm -rf "$target_dir/*"

    for so in ${vimbax}/lib/bin/*.so; do
      ln -sf "$so" "$target_dir"
    done
  '';

  propagatedBuildInputs = [ vimbax ] ++ pythonDeps;

  pythonImportsCheck = [ "vmbpy" ];
}
