{
  klipper,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

klipper.overrideAttrs (finalAttrs: {
  pname = "ender3-v3-se-klipper-with-display";
  version = "1.0.0-unstable-2025-02-26";

  src = fetchFromGitHub {
    owner = "jpcurti";
    repo = "ender3-v3-se-klipper-with-display";
    rev = "93886740c6f6f4bb4b233acc923c3e437f1bb428";
    hash = "sha256-AcK8B7vju/Wojx3h7ERurPZLk0cpxG3JA0HDXc1tk3s=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = finalAttrs.meta // {
    description = "Fork of klipper with auto Z-offset calibration & display support for the Ender3 V3 SE";
  };
})
