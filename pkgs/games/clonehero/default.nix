{ stdenv, fetchurl, autoPatchelfHook
, alsaLib, gtk2, libXrandr, libXScrnSaver, udev, zlib
}:

let
  name = "clonehero";
in stdenv.mkDerivation rec {
  pname = "${name}-unwrapped";
  version = "0.23.2.1";

  src = fetchurl {
    url = "http://dl.clonehero.net/${name}-v${stdenv.lib.removePrefix "0" version}/${name}-linux.tar.gz";
    sha256 = "0k75xivydqsxg9n34kk5a1kr4nbqjc6dlnd59mpc4mph10ri4gcr";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsaLib # ALSA sound
    gtk2
    libXrandr # X11 resolution detection
    libXScrnSaver # X11 screensaver prevention
    stdenv.cc.cc.lib
    udev # udev input drivers
    zlib
  ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/share"
    install -Dm755 ${name} "$out/bin"
    cp -r clonehero_Data "$out/share"
  '';

  # Patch required run-time libraries as load-time libraries
  #
  # Libraries found with:
  # > strings clonehero | grep '\.so'
  # and
  # > strace clonehero 2>&1 | grep '\.so'
  postFixup = ''
    patchelf \
      --add-needed libasound.so.2 \
      --add-needed libudev.so.1 \
      --add-needed libXrandr.so.2 \
      --add-needed libXss.so.1 \
      "$out/bin/${name}"
  '';

  meta = with stdenv.lib; {
    description = "Clone of Guitar Hero and Rockband-style games";
    homepage = https://clonehero.net/;
    maintainers = with maintainers; [ metadark ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
