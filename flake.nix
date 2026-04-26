{
  description = "Brave Origin Nightly Binary Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pname = "brave-origin-nightly";
      version = "1.91.113";
      
      libs = with pkgs; [
        alsa-lib
        at-spi2-atk
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libGL
        libx11
        libXScrnSaver
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXtst
        libdrm
        libuuid
        libxcb
        libxshmfence
        mesa
        nspr
        nss
        pango
        pipewire
        systemd
      ];
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        src = pkgs.fetchzip {
          url = "https://github.com/brave/brave-browser/releases/download/${version}/${pname}-${version}-linux-amd64.zip";
          sha256 = "sha256-HPBPzl/MBKviOSHhJ8f43XV6fXo9bPg/nI3Ut5ZKsas=";
          stripRoot = false;
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];
        buildInputs = libs;

        autoPatchelfIgnoreMissingDeps = [
          "libQt5Core.so.5"
          "libQt5Gui.so.5"
          "libQt5Widgets.so.5"
          "libQt6Core.so.6"
          "libQt6Gui.so.6"
          "libQt6Widgets.so.6"
        ];

        installPhase = ''
          mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

          cp -r * $out/opt/brave-origin/
          cp product_logo_256.png $out/share/icons/hicolor/256x256/apps/brave-origin-nightly.png

          cat > $out/share/applications/brave-origin-nightly.desktop << EOF
            [Desktop Entry]
            Name=Brave Origin Nightly
            Exec=$out/bin/brave-origin %U
            Icon=$out/share/icons/hicolor/256x256/apps/brave-origin-nightly.png
            Type=Application
            Categories=Network;WebBrowser;
            MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
            StartupWMClass=brave-origin-nightly
            EOF

          makeWrapper $out/opt/brave-origin/brave-origin-nightly $out/bin/brave-origin \
            --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath libs}" \
            --add-flags "--origin-mode"
        '';
      };
    };
}
