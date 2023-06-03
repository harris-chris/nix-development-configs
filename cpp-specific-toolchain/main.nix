{ stdenv
  , lib
}:
  stdenv.mkDerivation rec {
    name = "main";
    src = ./src/.;

    buildPhase = ''
      gcc -o main main.c
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp main $out/bin
    '';

    buildInputs = [];
  }
