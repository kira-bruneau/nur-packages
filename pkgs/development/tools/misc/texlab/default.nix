{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, help2man
, installShellFiles
, libiconv
, Security
, CoreServices
, nix-update-script
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
in
rustPlatform.buildRustPackage rec {
  pname = "texlab";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "latex-lsp";
    repo = "texlab";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-2P+aidfYkO8l9VjqTstXbksyGTQ3porJhrBYod9oCYQ=";
  };

  cargoSha256 = "sha256-Yr4i35Yf9kWYD1xQi+RKx6RQtyQUlZS8cXWkGGNuwXI=";

  outputs = [ "out" ] ++ lib.optional (!isCross) "man";

  nativeBuildInputs = [ installShellFiles ]
    ++ lib.optional (!isCross) help2man;

  buildInputs = lib.optionals stdenv.isDarwin [
    libiconv
    Security
    CoreServices
  ];

  # When we cross compile we cannot run the output executable to
  # generate the man page
  postInstall = lib.optionalString (!isCross) ''
    # TexLab builds man page separately in CI:
    # https://github.com/latex-lsp/texlab/blob/v5.4.0/.github/workflows/publish.yml#L127-L131
    help2man --no-info "$out/bin/texlab" > texlab.1
    installManPage texlab.1
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An implementation of the Language Server Protocol for LaTeX";
    homepage = "https://texlab.netlify.app";
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar kira-bruneau ];
    platforms = platforms.all;
  };
}
