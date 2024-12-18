{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  makeWrapper,
  nodejs,
  krb5,
  nix-update-script,
  callPackage,
  settings ? { },
}:

let
  resolvedSettings = {
    NODE_ENV = "production";

    # Disable amplitude analytics
    AMPLITUDE_KEY = "";
    AMPLITUDE_SECRET = "";

    # Disable google analytics
    GA_ID = "";

    # Disable loggly
    LOGGLY_CLIENT_TOKEN = "";
    LOGGLY_SUBDOMAIN = "";
    LOGGLY_TOKEN = "";
  } // settings;
in
buildNpmPackage rec {
  pname = "habitica";
  version = "5.31.2";

  outputs = [
    "out"
    "apidoc"
    "migrations"
  ];

  src = fetchFromGitHub {
    owner = "HabitRPG";
    repo = "habitica";
    tag = "v${version}";
    hash = "sha256-Ij+3D2Klt/eAOCdJ16+0olqXYCYHC4oALUAwTa/+43w=";
  };

  npmDepsHash = "sha256-5eG+h6b6QMSe74dij0spIvh6wwO/VHOJiD9SW931ejk=";

  postPatch = ''
    sed -i /postinstall/d package.json
    sed -i /gulp-imagemin/d package.json
  '';

  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [
    jq
    makeWrapper
  ];

  buildInputs = [
    krb5
  ];

  preConfigure = ''
    echo ${lib.escapeShellArg (builtins.toJSON resolvedSettings)} \
      | jq -s '.[0] * .[1]' config.json.example - > config.json
  '';

  buildPhase = ''
    runHook preBuild
    npx gulp build:prod
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit dev --no-save \
      $npmInstallFlags \
      "''${npmInstallFlagsArray[@]}" \
      $npmFlags \
      "''${npmFlagsArray[@]}"

    mkdir -p "$out/lib/node_modules/habitica"
    cp --parents -rt "$out/lib/node_modules/habitica" \
      config.json \
      content_cache \
      i18n_cache \
      node_modules \
      package.json \
      website/common/index.js \
      website/common/locales/*/*.json \
      website/common/transpiled-babel \
      website/transpiled-babel

    makeWrapper ${lib.getExe nodejs} "$out/bin/habitica" \
      --set NODE_ENV production \
      --chdir "$out/lib/node_modules/habitica" \
      --add-flags website/transpiled-babel/index.js

    cp -r apidoc/html "$apidoc"
    cp -r migrations "$migrations"

    runHook postInstall
  '';

  passthru = {
    inherit settings;
    client = callPackage ./client.nix { settings = resolvedSettings; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Habit tracker app which treats your goals like a Role Playing Game";
    homepage = "https://github.com/HabitRPG/habitica";
    license = with lib.licenses; [
      gpl3Only # Code
      cc-by-sa-30 # Mozilla BrowserQuest assets & content
      cc-by-nc-sa-30 # HabitRPG assets & content
    ];
    maintainers = with lib.maintainers; [ kira-bruneau ];
    mainProgram = "habitica";
    platforms = lib.platforms.all;
  };
}