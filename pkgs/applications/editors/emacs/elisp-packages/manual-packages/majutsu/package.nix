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
    rev = "e16a599f320091846846cfff6f0950a08ea41871";
    hash = "sha256-tssXhZ16ucTgzC5zTJL7daJ/wPnv2qZejA/QLz93fxQ=";
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
