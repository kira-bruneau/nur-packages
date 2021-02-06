{ lib
, buildPythonApplication
, fetchFromGitHub
, poetry
, pygls
, pyparsing
, cmake
, pytest-datadir
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "cmake-language-server";
  version = "0.1.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "regen100";
    repo = pname;
    rev = "v${version}";
    hash = "sha256:0vz7bjxkk0phjhz3h9kj6yr7wnk3g7lqmkqraa0kw12mzcfck837";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'pygls = "^0.8.1"' 'pygls = "^0.9.0"'
  '';

  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = [ pygls pyparsing ];

  checkInputs = [ cmake pytest-datadir pytestCheckHook ];
  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "CMake LSP Implementation";
    homepage = "https://github.com/regen100/cmake-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
