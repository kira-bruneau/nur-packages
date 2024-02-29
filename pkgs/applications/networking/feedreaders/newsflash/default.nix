{ lib
, stdenv
, rustPlatform
, fetchFromGitLab
, cargo
, meson
, ninja
, pkg-config
, rustc
, blueprint-compiler
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
, gitUpdater
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsflash";
  version = "3.1.5";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = "refs/tags/v.${finalAttrs.version}";
    hash = "sha256-6RkZdRQ/pNq6VkL9E2BaAWbKKGbCpEC+skGHPe3TwH8=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "news-flash-2.3.0-alpha.0" = "sha256-Gr7EyAbIFABZx9GR/WvshF0vfJaul7wz4pro2EbwSM8=";
      "newsblur_api-0.2.0" = "sha256-eysCB19znQF8mRwQ64nSp6KuvJ1Trot4g4WCdQDedo8=";
      "article_scraper-2.0.0" = "sha256-URiteEJ1kXoGfRopGoRI/4iPbzd+F9bQaMJKpkrh/sE=";
    };
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
    rustPlatform.cargoSetupHook
    cargo
    rustc
    blueprint-compiler
  ];

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

  passthru.updateScript = gitUpdater {
    rev-prefix = "v.";
  };

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau stunkymonkey ];
    platforms = platforms.unix;
    mainProgram = "io.gitlab.news_flash.NewsFlash";
    broken = stdenv.isDarwin; # webkitgtk doesn't build on Darwin
  };
})
