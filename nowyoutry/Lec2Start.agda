module Lec2Start where

open import Lec1Start


------------------------------------------------------------------------------
-- Vectors  -- the star of exercise 1
------------------------------------------------------------------------------

data Vec (X : Set) : Nat -> Set where  -- like lists, but length-indexed
  []   :                              Vec X zero
  _,-_ : {n : Nat} -> X -> Vec X n -> Vec X (suc n)
infixr 4 _,-_   -- the "cons" operator associates to the right


list : Vec Nat 5
list = (1 ,- 2 ,- 3 ,- 4 ,- 5 ,- [])

------------------------------------------------------------------------------
-- Taking a Prefix of a Vector
------------------------------------------------------------------------------

vTake : (m n : Nat) -> m >= n -> {X : Set} -> Vec X m -> Vec X n
vTake m zero m>=n xs = []
vTake (suc m) (suc n) m>=n (x ,- xs) = x ,- vTake m n m>=n xs

take3 : Vec Nat 3
take3 = vTake 5 3 <> list

------------------------------------------------------------------------------
-- Things to Prove
------------------------------------------------------------------------------

vTakeIdFact : (n : Nat){X : Set}(xs : Vec X n) ->
              vTake n n (refl->= n) xs == xs
vTakeIdFact zero [] = refl []
-- vTakeIdFact (suc n) (x ,- xs) rewrite vTakeIdFact n xs = refl (x ,- xs)
vTakeIdFact (suc n) (x ,- xs) with vTake n n (refl->= n) xs | vTakeIdFact n xs
... | .xs | refl .xs = refl (x ,- xs)

takeId : vTake 5 5 (refl->= 5) list == list
takeId = vTakeIdFact 5 list

vTakeCpFact : (m n p : Nat)(m>=n : m >= n)(n>=p : n >= p)
              {X : Set}(xs : Vec X m) ->
              vTake m p (trans->= m n p m>=n n>=p) xs ==
                vTake n p n>=p (vTake m n m>=n xs)
{- hit p first: why? -}                
vTakeCpFact m n zero m>=n n>=p xs = refl []
vTakeCpFact (suc m) (suc n) (suc p) m>=n n>=p (x ,- xs) rewrite vTakeCpFact m n p m>=n n>=p xs = refl (x ,- vTake n p n>=p (vTake m n m>=n xs))


------------------------------------------------------------------------------
-- Splittings (which bear some relationship to <= from ex1)
------------------------------------------------------------------------------

data _<[_]>_ : Nat -> Nat -> Nat -> Set where
  zzz : zero <[ zero ]> zero
  lll : {l m r : Nat} ->      l <[     m ]> r
                      ->  suc l <[ suc m ]> r
  rrr : {l m r : Nat} ->      l <[     m ]>     r
                      ->      l <[ suc m ]> suc r

_>[_]<_ : {X : Set}{l m r : Nat} ->
          Vec X l -> l <[ m ]> r -> Vec X r ->
          Vec X m
xl >[ rrr nnn ]< (x ,- xr) = x ,- (xl >[ nnn ]< xr)
[] >[ zzz ]< [] = []
(x ,- xl) >[ lll nnn ]< xr = x ,- (xl >[ nnn ]< xr)

data FindSplit {X : Set}{l m r : Nat}(nnn : l <[ m ]> r)
     : (xs : Vec X m) -> Set where
  splitBits : (xl : Vec X l)(xr : Vec X r) -> FindSplit nnn (xl >[ nnn ]< xr)

findSplit : {X : Set}{l m r : Nat}(nnn : l <[ m ]> r)(xs : Vec X m) ->
            FindSplit nnn xs
findSplit zzz [] = splitBits [] []
findSplit (lll nnn) (x ,- xs) with findSplit nnn xs
... | splitBits xl xr = splitBits (x ,- xl) xr
findSplit (rrr nnn) (x ,- xs) = help nnn x xs (findSplit nnn xs) where
  help : forall {X l m r} (nnn : l <[ m ]> r) (x : X) (xs : Vec X m) ->
         (r : FindSplit nnn xs) ->
         FindSplit (rrr nnn) (x ,- xs)
  help nnn x .(xl >[ nnn ]< xr) (splitBits xl xr) = splitBits xl (x ,- xr)

------------------------------------------------------------------------------
-- what I should remember to say
------------------------------------------------------------------------------

-- What's the difference between m>=n and m >= n ?
   {- m>=n (without spaces) is just an identifier; it could be anything,
      but it has been chosen to be suggestive of its *type* which is
      m >= n (with spaces) which is the proposition that m is at least n.
      By "proposition", I mean "type with at most one inhabitant", where
      we care more about whether there is an inhabitant or not than which
      one (because there's never a choice). Finished code does not show
      us the types of its components, and that's not always a good thing.
      Here, by picking nice names, we get something of an aide-memoire. -}

-- What does (x ,-_) mean?
   {- It's a "left section". Right sections (_,- xs) also exist sometimes.
      Why only sometimes? -}

-- "Why is it stuck?"
   {- Proof by induction isn't just flailing about, you know? The trick is
      to pick the case analysis that provokes the "stuck" programs to do a
      step of computation. Then the same reasoning that justifies the
      termination of the program will justify the induction in a proof
      about it. -}
      
