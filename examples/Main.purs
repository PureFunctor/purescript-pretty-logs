module Main where

import Prelude

import Effect (Effect)
import Logs.Pretty (CSS(..), LogSpec, logPretty, mkLogSpec)
import Type.Proxy (Proxy(..))


logBlack :: String -> Effect Unit
logBlack = logPretty <<< logBlack_
  where
    mkBlackSpec :: CSS -> String -> LogSpec
    mkBlackSpec = mkLogSpec ( Proxy :: _ "%c %s" )

    logBlack_ :: String -> LogSpec
    logBlack_ =
      mkBlackSpec ( CSS "background-color: black; color: white;" )


logSimple :: String -> Effect Unit
logSimple m = logPretty
  { message: "%c " <> m
  , styling: [ CSS "background-color: black; color: white;" ]
  }


main :: Effect Unit
main = do
  logBlack "In the beginning, there was silence..."
  logSimple "Types are pretty nice, but simplicity is also good."
