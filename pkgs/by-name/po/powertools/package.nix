{
  lib,
  stdenv,
  fetchFromGitea,
  cargo,
  cmake,
  nodejs,
  npmHooks,
  pnpm,
  rustc,
  rustPlatform,
  pciutils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "powertools";
  version = "2.0.3";

  src = fetchFromGitea {
    domain = "git.ngni.us";
    owner = "NG-SD-Plugins";
    repo = "PowerTools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xBqEZzV/Y9xnmWPW6KQbn7HVlbtzRKGQNGdRAGcOsLI=";
  };

  cargoRoot = "backend";

  buildAndTestSubdir = "backend";

  cargoBuildType = "release";

  cargoCheckType = finalAttrs.cargoBuildType;

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) pname version src;
    patches = [ ./fix-time.patch ];
    sourceRoot = "source/${finalAttrs.cargoRoot}";
    patchFlags = [ "-p2" ];
    hash = "sha256-3jXRIi9l1GOQInklxvjdVXf6GDbbDgdkGZpVUN3FaoA=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    patches = [ ./update-lock.patch ];
    hash = "sha256-zINfP3yKoQk95YElVFtnsNfqfuTVVv+5gTXoIdVZQuk=";
  };

  patches = [
    ./fix-tests.patch
    ./fix-time.patch
    ./update-lock.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    cmake
    nodejs
    pnpm.configHook
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoBuildHook
    rustPlatform.cargoCheckHook
    rustPlatform.cargoInstallHook
    rustPlatform.cargoSetupHook
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [ pciutils ];

  npmBuildScript = "build";

  postBuild = ''
    pnpm run build
  '';

  postInstall = ''
    mv "$out/bin/powertools" "$out/bin/backend"
    cp -r default_settings.ron limits_override.ron main.py plugin.json translations dist "$out"
  '';

  meta = with lib; {
    description = "Steam Deck power tweaks for power users";
    homepage = "https://git.ngni.us/NG-SD-Plugins/PowerTools";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "backend";
    platforms = platforms.all;
  };
})
