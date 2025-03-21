{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mozlz4";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jusw85";
    repo = "mozlz4";
    tag = "v${finalAttrs.version}";
    hash = "sha256-faoFvDvqCr0EPsqlQvHZpd74b5pzYhtkJ6gXebwEm/w=";
  };

  useFetchCargoVendor = false; # Uses old Cargo.lock format that doesn't work with fetchCargoVendor
  cargoHash = "sha256-/R4UQky0gAwh465HjlePoxUTcYWbgS5n+sJ+kkWzDw0=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Decompress / compress mozlz4 files";
    homepage = "https://github.com/jusw85/mozlz4";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "mozlz4";
  };
})
