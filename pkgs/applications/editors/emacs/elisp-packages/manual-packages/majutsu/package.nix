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
  version = "0.6.0-unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "58f047488097aa5ac929b7d32375ab9db16f827e";
    hash = "sha256-Nv7k8y0ekaWSsFuMJm4+4pAD112HPNnU/xQDJI1qryo=";
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
