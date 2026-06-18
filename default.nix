{pkgs}: let
  srcRpm = pkgs.requireFile {
    name = "sqldeveloper-24.3.1-347.1826.noarch.rpm";
    sha256 = "cbb20f90cf67305673eb01fd1c222790d551a9c306fef45903c38af96c62b838";
  };

  fhsEnv = pkgs.buildFHSEnv {
    name = "sqldeveloper-fhs-env";

    targetPkgs = pkgs:
      with pkgs; [
        openjdk21
        glib
        gtk3
        adwaita-icon-theme
        libX11
        libXext
        libXrender
        libXrandr
        libXcursor
        libXinerama
        libxcb
        libXi
        libXtst
        libGL
        mesa
        vulkan-loader
        fontconfig
        freetype
        gdk-pixbuf
        cairo
        pango
        atk
        dbus
        libsoup_3
        webkitgtk_4_1
      ];

    runScript = "bash";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "sqldeveloper";
    version = "24.3.1";

    src = srcRpm;

    nativeBuildInputs = with pkgs; [rpm cpio makeWrapper];

    unpackPhase = ''
      rpm2cpio $src | cpio -idmv --no-absolute-filenames
    '';

    installPhase = ''
          mkdir -p $out/opt
          cp -r opt/sqldeveloper $out/opt/

          SQLEXE=$out/opt/sqldeveloper/sqldeveloper.sh

          mkdir -p $out/bin

          makeWrapper ${fhsEnv}/bin/sqldeveloper-fhs-env $out/bin/sqldeveloper \
            --add-flags "$SQLEXE" \
            --set JAVA_HOME "${pkgs.openjdk21}" \
            --set JDK_JAVA_OPTIONS "
              -Dawt.useSystemAAFontSettings=on
              -Dswing.aatext=true
              -Dsun.java2d.opengl=true
              --add-exports=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED
              --add-opens=java.desktop/javax.swing.plaf.synth=ALL-UNNAMED
              --add-opens=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED
            ";

          mkdir -p $out/share/applications

          cat > $out/share/applications/sqldeveloper.desktop <<EOF
      [Desktop Entry]
      Name=Oracle SQL Developer
      Exec=sqldeveloper
      Type=Application
      Categories=Development;Database;
      Terminal=false
      StartupWMClass=SQL Developer
      EOF
    '';

    meta = with pkgs.lib; {
      description = "Oracle SQL Developer";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  }
