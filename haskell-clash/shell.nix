let
  clash-only-shell = import ./clash-only-shell.nix {};
in
(import ./default.nix).shellFor {
  tools = {
    cabal = "3.2.0.0";
    hlint = "latest";
    #haskell-language-server = "latest";
  };
  inputsFrom = [ clash-only-shell ];
}
