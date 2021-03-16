{ lib
, buildPythonPackage
, isPy3k
, fetchFromGitHub
, psutil
, pydantic
, typeguard
, mock
, pytest-asyncio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "0.10.0";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-n+fO5b4CCau2yHwxGbsGQ4eCcmeI5pScME7HKfSFY/s=";
  };

  propagatedBuildInputs = [
    psutil
    pydantic
    typeguard
  ];

  checkInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    license = licenses.asl20;
    maintainers = with maintainers; [ metadark ];
  };
}
