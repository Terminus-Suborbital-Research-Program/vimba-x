{ lib, stdenv, autoPatchelfHook, python312, python312Packages, vimbax }:

let
  archSuffix = if stdenv.hostPlatform.system == "x86_64-linux" then
    "linux_x86_64"
  else if stdenv.hostPlatform.system == "aarch64-linux" then
    "linux_aarch64"
  else
    throw "Unsupported System!";

  version = "1.1.0";

  wheelName = "vmbpy-${version}-py3-none-${archSuffix}.whl";

  pythonDeps = with python312Packages; [ numpy opencv-python ];
in python312Packages.buildPythonPackage {
  pname = "vmbpy";
  inherit version;
  format = "wheel";

  src = "${vimbax}/lib/api/python/${wheelName}";

  preFixup = ''
    target_dir="$out/${python312.sitePackages}/vmbpy/c_binding/lib"
    mkdir -p "$target_dir"
    rm -rf "$target_dir/*"

    for so in ${vimbax}/lib/bin/*.so; do
      ln -sf "$so" "$target_dir"
    done
  '';

  postFixup = ''
    {
      echo 'import os'
      echo 'os.environ.setdefault("GENICAM_GENTL64_PATH", "${vimbax}/lib/cti")'
      cat $out/${python312.sitePackages}/vmbpy/__init__.py
    } > tmp

      mv tmp $out/${python312.sitePackages}/vmbpy/__init__.py
  '';

  propagatedBuildInputs = [ vimbax ] ++ pythonDeps;

  pythonImportsCheck = [ "vmbpy" ];
}
