{ customStdenv
  , lib
}:
  customStdenv.mkDerivation rec {
    name = "main";
    src = ./src/.;

    buildPhase = ''
      g++ -o main main.cpp
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp main $out/bin
    '';

    buildInputs = [];
  }
