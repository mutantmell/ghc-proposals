module Example where

import qualified Data.Foldable as F
import           Data.Coerce (coerce)
import           Data.Monoid (All(..), getAll)
import           Data.Maybe  (Maybe, maybe)

data Foo = Foo
  { fooName :: String
  , fooInt :: Int
  }

mkFilterCoerce :: -- Filter a list of ``Foo`` s by a name and an int
  String ->
  Int ->
  [Foo] -> [Foo]
mkFilterCoerce name int = filter predicates
  where
    predicates = coerce fold
    fold = F.fold $ (coerce [namePredicate, intPredicate] :: [Foo -> All])

    namePredicate foo = name == fooName foo
    intPredicate foo = int == fooInt foo

mkFilterProposal :: -- Filter a list of ``Foo`` s by a name and an int
  String ->
  Int ->
  [Foo] -> [Foo]
mkFilterProposal name int = filter predicates
  where
    predicates = F.fold [namePredicate, intPredicate]@[Foo -> All]

    namePredicate foo = name == fooName foo
    intPredicate foo = int == fooInt foo
