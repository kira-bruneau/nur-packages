{ lib
, stdenv
, rustPlatform
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, libxml2
, openssl
, sqlite
, webkitgtk
, glib-networking
, librsvg
, gst_all_1
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsflash";
  version = "2.0.1";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = "refs/tags/v.${finalAttrs.version}";
    hash = "sha256-bqS9jq1rUOkYilWzp0e2tlEcgmoc+DUV7+LJ82Bid98=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    src = finalAttrs.src;
    hash = "sha256-vD880Ccp+U4kz7/JbJ850M/XxCb1ypycd2Xm9NHDVRY=";
  };

  patches = [
    # Post install tries to generate an icon cache & update the
    # desktop database. The gtk setup hook drop-icon-theme-cache.sh
    # would strip out the icon cache and the desktop database wouldn't
    # be included in $out. They will generated by xdg.mime.enable &
    # gtk.iconCache.enable instead.
    ./no-post-install.patch
  ];

  postPatch = ''
    patchShebangs build-aux/cargo.sh
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

    # Provides glib-compile-resources to compile gresources
    glib
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
  ]);

  buildInputs = [
    gtk4
    libadwaita
    libxml2
    openssl
    sqlite
    webkitgtk

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # SVG support for gdk-pixbuf
    librsvg
  ] ++ (with gst_all_1; [
    # Audio & video support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau stunkymonkey ];
    platforms = platforms.unix;
    mainProgram = "com.gitlab.newsflash";
    broken = stdenv.isDarwin; # webkitgtk doesn't build on Darwin
  };
})
