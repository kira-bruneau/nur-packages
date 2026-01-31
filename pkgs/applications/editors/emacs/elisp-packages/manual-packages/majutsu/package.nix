{
  lib,
  melpaBuild,
  fetchFromGitHub,
  magit,
  evil,
  nix-update-script,
}:

melpaBuild (finalAttrs: {
  pname = "majutsu";
  version = "0.5.0-unstable-2026-01-31";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "71937b0150123e4b6f57c753912b1b4154f1d990";
    hash = "sha256-osbswyRUj4jyNs/swglfHZoiQVw3joHKN6XwFerCJCU=";
  };

  packageRequires = [
    magit
    evil
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Magit for jujutsu";
    homepage = "https://github.com/0WD0/majutsu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
