{
  lib,
  python3,
  melpaBuild,
  fetchFromGitHub,
  replaceVars,
  acm,
  markdown-mode,
  basedpyright,
  git,
  go,
  gopls,
  tempel,
  unstableGitUpdater,
  writableTmpDirAsHomeHook,
}:

let
  python = python3.withPackages (
    ps: with ps; [
      epc
      orjson
      packaging
      paramiko
      rapidfuzz
      setuptools
      sexpdata
      six
      watchdog
    ]
  );
in
melpaBuild {
  pname = "lsp-bridge";
  version = "0-unstable-2025-04-16";

  src = fetchFromGitHub {
    owner = "manateelazycat";
    repo = "lsp-bridge";
    rev = "16c4f234e9e0debbbf68464c34e55122a979d48d";
    hash = "sha256-YEBr1JHexLbQURP8K0IrbJlqo7FlhQHxKrbj0lIDFf4=";
  };

  patches = [
    # Hardcode the python dependencies needed for lsp-bridge, so users
    # don't have to modify their global environment
    (replaceVars ./hardcode-dependencies.patch {
      python = python.interpreter;
    })
  ];

  packageRequires = [
    acm
    markdown-mode
  ];

  checkInputs = [
    # Emacs packages
    tempel
  ];

  nativeCheckInputs = [
    # Executables
    basedpyright
    git
    go
    gopls
    python
    writableTmpDirAsHomeHook
  ];

  files = ''
    ("*.el"
     "lsp_bridge.py"
     "core"
     "langserver"
     "multiserver"
     "resources")
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    mkfifo test.log
    cat < test.log &
    python -m test.test

    runHook postCheck
  '';

  __darwinAllowLocalNetworking = true;

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "Blazingly fast LSP client for Emacs";
    homepage = "https://github.com/manateelazycat/lsp-bridge";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      fxttr
      kira-bruneau
    ];
  };
}
