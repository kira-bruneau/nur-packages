{ stdenv, buildPythonApplication, fetchFromGitHub
, poetry, pygls, pyparsing,
}:

buildPythonApplication rec {
  pname = "cmake-language-server";
  version = "0.1.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "regen100";
    repo = pname;
    rev = "v${version}";
    sha256 = "09rijjksx07inbwxjinrsqihkxb011l2glysasmwpkhy0rmmhbcm";
  };

  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = [ pygls pyparsing ];

  meta = with stdenv.lib; {
    description = "CMake LSP Implementation";
    homepage = "https://github.com/regen100/cmake-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
