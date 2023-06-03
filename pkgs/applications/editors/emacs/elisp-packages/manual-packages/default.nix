pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  acm = callPackage ./acm { };

  lsp-bridge = callPackage ./lsp-bridge {
    inherit (pkgs) python3 git go gopls pyright;
  };
}
