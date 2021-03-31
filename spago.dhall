{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "pretty-logs"
, dependencies =
  [ "console", "effect", "newtype", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
