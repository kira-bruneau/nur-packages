{ lib
, stdenv
, fetchurl

# Required build tools
, bison
, flex
, gettext
, help2man
, makeWrapper
, pkg-config
, texinfo

# Required runtime libraries
, boehmgc
, readline

# Optional runtime libraries
# TODO: Enable guiSupport by default once it's more than just a stub
# TODO: Add nbdSupport, requires packaging libndb
, guiSupport ? false, tcl, tcllib, tk
, miSupport ? true, json_c
, textStylingSupport ? true

# Test libraries
, dejagnu
}:

stdenv.mkDerivation rec {
  pname = "poke";
  version = "1.0";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    hash = "sha256-3pMLhwDAdys8LNDQyjX1D9PXe9+CxiUetRa0noyiWwo=";
  };

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    gettext
    help2man
    makeWrapper
    pkg-config
    texinfo
  ];

  buildInputs = [ boehmgc dejagnu readline ]
  ++ lib.optional guiSupport tk
  ++ lib.optional miSupport json_c
  ++ lib.optional textStylingSupport gettext;

  configureFlags = lib.optionals guiSupport [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
    "--with-tkinclude=${tk.dev}/include"
  ];

  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ dejagnu ];

  postFixup = lib.optionalString guiSupport ''
    wrapProgram "$out/bin/poke-gui" \
      --prefix TCLLIBPATH ' ' ${tcllib}/lib/tcllib${tcllib.version}
  '';

  meta = with lib; {
    description = "Interactive, extensible editor for binary data";
    homepage = "http://www.jemarch.net/poke";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.unix;
  };
}
