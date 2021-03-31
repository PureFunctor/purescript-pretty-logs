module Main where

import Prelude

import Effect (Effect)
import Logs.Pretty (LogSpec, logPretty, mkLogSpec)
import Type.Proxy (Proxy(..))


logBlack :: String -> Effect Unit
logBlack = logPretty <<< logBlack_
  where
    mkBlackSpec :: String -> String -> LogSpec
    mkBlackSpec = mkLogSpec ( Proxy :: _ "%c %s" )

    logBlack_ :: String -> LogSpec
    logBlack_ message =
      mkBlackSpec message "background-color: black; color: white;"


main :: Effect Unit
main = do
  logBlack "In the beginning, there was silence..."
