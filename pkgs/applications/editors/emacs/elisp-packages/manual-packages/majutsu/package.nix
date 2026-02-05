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
  version = "0.5.0-unstable-2026-02-05";

  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "d54a91dd65145c18fb589dad91216ee82d92bfca";
    hash = "sha256-5BoksUv85iom/p51Uu8SxZlSU0pf/42NFEaiBgb1Il8=";
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
