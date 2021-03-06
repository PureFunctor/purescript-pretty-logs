module Logs.Pretty where

import Prelude

import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (class IsSymbol, reflectSymbol)
import Effect (Effect)
import Prim.Symbol as Symbol
import Type.Proxy (Proxy(..))

{-----------------------------------------------------------------------}

-- | List of format specifiers.
data FList

foreign import data FNil :: FList
foreign import data FCons :: FType -> FList -> FList

{-----------------------------------------------------------------------}

-- | Type of format specifiers.
data FType

-- | Specifier for strings.
foreign import data FString :: FType

-- | Specifier for showable types.
foreign import data FShowable :: FType

-- | Specifier for `%c` literals.
foreign import data FStyling :: FType

-- | Specifier for literal strings.
foreign import data FLiteral :: Symbol -> FType

{-----------------------------------------------------------------------}

-- | Reads an `FType` from a string.
class ReadF ( i :: Symbol ) ( o :: FType ) | i -> o

instance readFs :: ReadF "s" FString
instance readFS :: ReadF "S" FShowable
instance readFc :: ReadF "c" FStyling

{-----------------------------------------------------------------------}

-- | Parses an `FList` from a string.
class Parse ( s :: Symbol ) ( a :: FList ) | s -> a

instance parseEnd :: Parse "" ( FCons ( FLiteral "" ) FNil )

else

instance parseCons :: (Symbol.Cons h t s, ParseImpl h t a) => Parse s a

{-----------------------------------------------------------------------}

-- | Parses an `FList` from a string, helps ease infinite types.
class ParseImpl ( h :: Symbol ) ( t :: Symbol ) ( a :: FList ) | h t -> a

instance parseImplEnd :: ParseImpl h "" ( FCons ( FLiteral h ) FNil )

else

instance parseImplFmt ::
  ( Symbol.Cons f n t
  , ReadF f f'
  , Parse n r
  ) => ParseImpl "%" t ( FCons ( FLiteral "" ) ( FCons f' r ) )

else

instance parseImplStr ::
  ( Parse t ( FCons ( FLiteral next ) r )
  , Symbol.Cons h next rest
  ) => ParseImpl h t ( FCons ( FLiteral rest ) r )

{-----------------------------------------------------------------------}

-- | Creates a variadic function `f` for creating a `LogSpec` by
-- | parsing the provided type-level symbol.
class MakeLogSpec ( s :: Symbol ) f | s -> f where
  mkLogSpec :: Proxy s -> f

instance mkLogSpecDefault ::
  ( Parse s l
  , MakeLogSpecImpl l f
  ) => MakeLogSpec s f where
  mkLogSpec _ = mkLogSpecImpl ( Proxy :: Proxy l ) []

{-----------------------------------------------------------------------}

-- | Creates a variadic function `f` for creating a `LogSpec` by
-- | traversing the provided list of format specifiers.
class MakeLogSpecImpl ( l :: FList ) f | l -> f where
  mkLogSpecImpl :: Proxy l -> ( Array CSS ) -> f

instance mkLogSpecImplDefault ::
  ( MakeLogSpecCss l l f
  ) => MakeLogSpecImpl l f where
  mkLogSpecImpl l = mkLogSpecCss l l

{-----------------------------------------------------------------------}

-- | Emits `CSS` arguments for the variadic function `f`.
class MakeLogSpecCss ( k :: FList )( l :: FList ) f | l -> f where
  mkLogSpecCss :: Proxy k -> Proxy l -> ( Array CSS ) -> f

instance mkLogSpecCssEnd ::
  ( MakeLogSpecFmt k f
  ) => MakeLogSpecCss k FNil f where
  mkLogSpecCss _ _ styles = mkLogSpecFmt styles ( Proxy :: Proxy k ) ""

else

instance mkLogSpecCssConsC ::
  ( MakeLogSpecCss k r f
  ) => MakeLogSpecCss k ( FCons FStyling r ) ( CSS -> f ) where
  mkLogSpecCss m _ xs x = mkLogSpecCss m ( Proxy :: Proxy r ) ( xs <> [ x ] )

else

instance mkLogSpecCssConsA ::
  ( MakeLogSpecCss k r f
  ) => MakeLogSpecCss k ( FCons s r ) f where
  mkLogSpecCss m _ = mkLogSpecCss m ( Proxy :: Proxy r )

{-----------------------------------------------------------------------}

-- | Emits string formatting arguments for the variadic function `f`.
class MakeLogSpecFmt ( l :: FList ) f | l -> f where
  mkLogSpecFmt :: ( Array CSS ) -> Proxy l -> String -> f

instance mkLogSpecFmtEnd :: MakeLogSpecFmt FNil LogSpec where
  mkLogSpecFmt styling _ message  = { message, styling }

else

instance mkLogSpecFmtConsString ::
  ( MakeLogSpecFmt r f
  ) => MakeLogSpecFmt ( FCons FString r ) ( String -> f ) where
  mkLogSpecFmt styling _ str s = mkLogSpecFmt styling ( Proxy :: Proxy r ) ( str <> s )

else

instance mkLogSpecFmtConsS ::
  ( MakeLogSpecFmt r f
  , Show s
  ) => MakeLogSpecFmt ( FCons FShowable r ) ( s -> f ) where
  mkLogSpecFmt styling _ str s = mkLogSpecFmt styling ( Proxy :: Proxy r ) ( str <> show s )

else

instance mkLogSpecFmtConsC ::
  ( MakeLogSpecFmt r f
  ) => MakeLogSpecFmt ( FCons FStyling r ) f where
  mkLogSpecFmt styling _ str = mkLogSpecFmt styling ( Proxy :: Proxy r ) ( str <> "%c" )

else

instance mkLogSpecFmtConsL ::
  ( IsSymbol l
  , MakeLogSpecFmt r f
  ) => MakeLogSpecFmt ( FCons ( FLiteral l ) r ) f where
  mkLogSpecFmt styling _ str = mkLogSpecFmt styling ( Proxy :: Proxy r ) ( str <> reflectSymbol ( Proxy :: Proxy l ) )

{-----------------------------------------------------------------------}

-- | Newtype wrapper for inline CSS.
newtype CSS = CSS String

derive instance newtypeCss :: Newtype CSS _


-- | Represents arguments used for `console.log`.
-- |
-- | Used in the following manner internally:
-- |
-- | ```javascript
-- | console.log(message, ...styling)
-- | ```
type LogSpec =
  { message :: String
  , styling :: Array CSS
  }

{-----------------------------------------------------------------------}

foreign import logPretty_ :: String -> Array String -> Effect Unit

-- | Performs logging using a provided `LogSpec`.
logPretty :: LogSpec -> Effect Unit
logPretty { message, styling } = logPretty_ message (unwrap <$> styling)
