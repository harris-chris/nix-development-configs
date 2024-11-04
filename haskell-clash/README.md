### Some basic instructions

- Use `nix develop .#` to enter a nix environment with the clash compiler already available (ie, `clashi` is on $PATH)
- Use `cabal run -- iclash -ilib` to start the clash REPL with the library in the `lib` folder available
- From the REPL, use `:l MAC` to load the MAC module
