{ mergedPkgs, pythonPackages }:

mergedPkgs.lib.fix (self:
let
  mergedPythonPackages = pythonPackages // self;
  callPackage = mergedPkgs.newScope mergedPythonPackages;
in
with mergedPythonPackages; {
  inherit callPackage;

  aamp = callPackage ./aamp { };

  botw-havok = callPackage ./botw-havok { };

  botw-utils = callPackage ./botw-utils { };

  byml = callPackage ./byml { };

  debugpy = callPackage ./debugpy { };

  lunr = callPackage ./lunr { };

  mkdocs = callPackage ./mkdocs { };

  oead = callPackage ./oead {
    inherit (mergedPkgs) cmake;
  };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  rstb = callPackage ./rstb { };

  vdf = callPackage ./vdf { };
})
