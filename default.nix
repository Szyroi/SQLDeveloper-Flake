{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "sqldeveloper";
  version = "24.3.1";

  src = pkgs.fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.1-347.1826.noarch.rpm";
    sha256 = "cbb20f90cf67305673eb01fd1c222790d551a9c306fef45903c38af96c62b838";
  };

  nativeBuildInputs = with pkgs; [rpm cpio makeWrapper];

  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  installPhase = ''
    mkdir -p $out
    cp -r opt $out/

    mkdir -p $out/bin

    SQLEXE=$out/opt/sqldeveloper/sqldeveloper.sh

    makeWrapper $SQLEXE $out/bin/sqldeveloper \
      --set JAVA_HOME ${pkgs.openjdk21} \
      --set JDK_JAVA_OPTIONS "--add-exports=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED --add-opens=java.desktop/javax.swing.plaf.synth=ALL-UNNAMED --add-opens=java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED"
  '';

  meta = {
    description = "SQL Developer";
    license = pkgs.lib.licenses.unfree;
    platforms = ["x86_64-linux"];
  };
}
