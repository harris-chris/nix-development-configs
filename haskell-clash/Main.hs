module Main where

import HaskellSay (haskellSay)

main :: IO ()
main =
  haskellSay "Hello, Haskell! You're using a function from another package!"
