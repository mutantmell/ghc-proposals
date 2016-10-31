.. proposal-number:: Leave blank. This will be filled in when the proposal is
                     accepted.

.. trac-ticket:: Leave blank. This will eventually be filled with the Trac
                 ticket number which will track the progress of the
                 implementation of the feature.

.. implemented:: Leave blank. This will be filled in with the first GHC version which
                 implements the described feature.

.. highlight:: haskell

Visible Type Coercion
==============

We propose the ability to use a type application-like syntax in order to temporarily
coerce a type when passed into a function.

Motivation
----------

One of the more novel features of Haskell is the ability to specify a typeclass.
The community and core contributors have embraced the ad-hoc polymorphism that 
typeclasses enable, perhaps most famously with ``Monad`` s.

One of the most important features of typeclasses is "canonicity", i.e. that 
there can be at most one instance of a particular typeclass for a particular
type.  While canonicity provides many benefits, it doesn't offer a solution for
types that have more than one "natural" instance for a typeclass. For example,
``Int`` has a reasonable ``Monoid`` over both addition and multiplication.

To solve this, ``Int`` has no ``Monoid`` monoid instance; instead, there are both
a ``Sum`` newtype and a ``Product`` newtype that can contain an ``Int`` , and they
implement the ``Monoid`` typeclass. In order to make this convenient, GHC provides
a ``Coercible`` typeclass,  which allows uses to manually use the ``coerce`` function
to convert back and forth, and automatically generates ``Coercible`` instance to and
from the newtype.

While this solution works technically, in practice it can prove to be unwieldy:

1. These newtypes are not often useful outside of their typeclass instances, and
   must be coerced back in order to continue the computation.  In particular, 
   most code is written with the base type in mind (``Int`` vs. ``Sum`` / ``Product``), making 
   it awkward to integrate these newtypes with existing code.

2. In the (common) case where there are multiple coercible types, the author has
   to manually provide typing information around the calls to coerce.


Proposed Change
---------------

We propose the addition of a new language extension:

``{-# LANGUAGE VisibleTypeCoercion #-}``

This lets you write:

.. code-block:: haskell
    import qualified Data.Foldable as F
    import           Data.Monoid (All(..))

    foo f x = f x@Type
    
    -- concrete example
    all :: [Bool] -> Bool
    all bools = F.fold bools@[All]``

Which is reminiscent of the recent Visible Type Application extension.

The extension has the following semantics.

* When applied to a value of type S, and coercing to a T, both ``Coercible S T`` and
  ``Coericible T S`` must be in scope.

* This de-sugars to a call to coerce the type, then a call to coerce on the entire result.
  Hmm, this may not work out cleanly, as it is not intuitively obvious where the back should be...
  Probably around the result of the entire function?

``allGT3 ints = F.foldMap (>3)@(Int -> All) ints`` ==>
``allGT3 ints = coerce (F.foldMap (coerce (>3)) ints)
``complicated f = foo (bar a) (baz f@(Int -> All) x y z)``, where ``baz`` does not return the expected type...
This seems pretty complicated to do in the result.

What about a function that takes an ``Any`` and returns an ``All`` ???


Drawbacks
---------

What are the reasons for *not* adopting the proposed change. These might include
complicating the language grammar, poor interactions with other features, 

Alternatives
------------

Here is where you can describe possible variants to the approach described in
the Proposed Change section.

Unresolved Questions
--------------------

Are there any parts of the design that are still unclear? Hopefully this section
will be empty by the time the proposal is brought up for a final decision.
