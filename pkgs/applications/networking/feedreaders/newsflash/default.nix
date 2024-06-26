{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitLab,
  substituteAll,
  cargo,
  meson,
  ninja,
  pkg-config,
  rustc,
  blueprint-compiler,
  wrapGAppsHook4,
  gdk-pixbuf,
  glib,
  clapper,
  gtk4,
  libadwaita,
  libxml2,
  openssl,
  sqlite,
  webkitgtk,
  glib-networking,
  librsvg,
  gst_all_1,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsflash";
  version = "3.3.0";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = "refs/tags/v.${finalAttrs.version}";
    hash = "sha256-s8h/OIJJzMmsCsaQJ0SOjCAVXfYQbjOupdDtLOqM9d0=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "clapper-0.1.0" = "sha256-xQ7l6luO5E4PMjtN9elg0bkJa7IhWzA7KuYDJ+m/VY0=";
      "news-flash-2.3.0-alpha.0" = "sha256-ZgX6tQmPDMSpLcYD04u2ReQXdzeGzQTwGaUy/y4z4do=";
      "newsblur_api-0.3.0" = "sha256-m2178zdJzeskl3BQpZr6tlxTAADehxz8uYcZzi15nhQ=";
    };
  };

  patches = [
    # Post install tries to generate an icon cache & update the
    # desktop database. The gtk setup hook drop-icon-theme-cache.sh
    # would strip out the icon cache and the desktop database wouldn't
    # be included in $out. They will generated by xdg.mime.enable &
    # gtk.iconCache.enable instead.
    ./no-post-install.patch

    # Replace placeholder "0.0.0" project version with nixpkgs version
    (substituteAll {
      src = ./hardcode-version.patch;
      inherit (finalAttrs) version;
    })
  ];

  postPatch = ''
    patchShebangs build-aux/cargo.sh
  '';

  strictDeps = true;

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

  buildInputs =
    [
      clapper
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
    ]
    ++ (with gst_all_1; [
      # Audio & video support for webkitgtk WebView
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
    ]);

  passthru.updateScript = gitUpdater { rev-prefix = "v."; };

  meta = with lib; {
    description = "Modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      kira-bruneau
      stunkymonkey
    ];
    platforms = platforms.unix;
    mainProgram = "io.gitlab.news_flash.NewsFlash";
    broken = stdenv.isDarwin; # webkitgtk doesn't build on Darwin
  };
})
