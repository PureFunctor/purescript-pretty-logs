# purescript-pretty-logs
Type-safe prettified `console.log` for PureScript, derived from [safe-printf](https://github.com/kcsongor/purescript-safe-printf).

## Introduction
`pretty-logs` provides a type-safe interface for creating prettified and formatted `console.log` messages on browsers. For example:
```purescript
logBlack :: String -> Effect Unit
logBlack = logPretty <<< logBlack_
  where
    mkBlackSpec :: CSS -> String -> LogSpec
    mkBlackSpec = mkLogSpec ( Proxy :: _ "%c %s" )
    -- [1] `mkLogSpec` creates a variadic function resulting in a `LogSpec`.
    --
    --     In this case, the type-level symbol "%c %s" produces a function
    --     that takes a `CSS` and a `String`.
    --
    --     Note that regardless of the ordering of the format specifiers,
    --     `CSS` arguments are always emitted first in order to support
    --     partial function application in a clean manner.
    logBlack_ :: String -> LogSpec
    logBlack_ =
      mkBlackSpec ( CSS "background-color: black; color: white;" )
    -- [2] You can then partially apply `mkBlackSpec` with inline CSS
    --     styling to create a function that can be composed with `logPretty`.

main :: Effect Unit
main = do
  logBlack "In the beginning, there was silence..."
```
It is also possible to use `pretty-logs` with an unchecked `LogSpec` for simpler usages:
```purescript
logSimple :: String -> Effect Unit
logSimple m = logPretty
  { message: "%c " <> m
  , styling: [ CSS "background-color: black; color: white;" ]
  }

main :: Effect Unit
main = do
  logSimple "Types are pretty nice, but simplicity is also good."
```

## Installation
```sh
$ spago install pretty-logs
```
or if not present within a package set, add the following to your project's `packages.dhall`:
```dhall
let upstream =
      ... 

in  upstream
      with pretty-logs =
        { repo "https://github.com/PureFunctor/purescript-pretty-logs"
        , dependencies =
          [ "console"
          , "effect"
          , "newtype"
          , "prelude"
          ]
        , version = "..."
        }
```
