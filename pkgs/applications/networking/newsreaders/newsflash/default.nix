{ lib
, rustPlatform
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook
, gdk-pixbuf
, glib
, gtk3
, libhandy
, openssl
, sqlite
, webkitgtk
, glib-networking
, gstreamer
, gst-plugins-base
, gst-plugins-good
, gst-plugins-bad
, librsvg
}:

rustPlatform.buildRustPackage rec {
  pname = "newsflash";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = version;
    sha256 = "1y2jj3z08m29s6ggl8q270mqnvdwibs0f2kxybqhi8mya5pyw902";
  };

  cargoPatches = [
    ./cargo.lock.patch
  ];

  cargoSha256 = "0z3nhzpyckga112wn32zzwwlpqdgi6n53n8nwgggixvpbnh98112";

  patches = [
    ./no-post-install.patch
  ];

  postPatch = ''
    chmod +x build-aux/cargo.sh
    patchShebangs .
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

    # Provides glib-compile-resources to compile gresources
    glib
  ];

  buildInputs = [
    gtk3
    libhandy
    openssl
    sqlite
    webkitgtk

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # Video & audio support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad

    # SVG support for gdk-pixbuf
    librsvg
  ];

  # Unset default rust phases to use meson & ninja instead
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;
  installCheckPhase = null;

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
