Tom de Jong, Nicolai Kraus, Fredrik Nordvall Forsberg, Chuangjie Xu,
13 November 2023.

\begin{code}

{-# OPTIONS --safe --without-K --no-exact-split #-}

open import UF.Univalence

module Ordinals.Exponentiation
       (ua : Univalence)
       where

open import UF.Base
open import UF.Embeddings hiding (⌊_⌋)
open import UF.Equiv
open import UF.EquivalenceExamples
open import UF.ExcludedMiddle
open import UF.FunExt
open import UF.Sets
open import UF.Subsingletons
open import UF.Subsingletons-FunExt
open import UF.UA-FunExt

private
 fe : FunExt
 fe = Univalence-gives-FunExt ua

 fe' : Fun-Ext
 fe' {𝓤} {𝓥} = fe 𝓤 𝓥

 pe : PropExt
 pe = Univalence-gives-PropExt ua

open import MLTT.Plus-Properties
open import MLTT.Spartan
open import MLTT.Sigma
-- open import Notation.CanonicalMap
open import Ordinals.Arithmetic fe
open import Ordinals.ArithmeticProperties ua
open import Ordinals.ConvergentSequence ua
open import Ordinals.Equivalence
open import Ordinals.Maps
open import Ordinals.Notions
open import Ordinals.OrdinalOfOrdinals ua
open import Ordinals.Type
open import Ordinals.Underlying

-- our imports
open import MLTT.List


data lex {X : 𝓤 ̇  } (R : X → X → 𝓥 ̇  ) : List X → List X → 𝓤 ⊔ 𝓥 ̇  where
 []-lex : {y : X}{ys : List X} → lex R [] (y ∷ ys)
 head-lex : {x y : X}{xs ys : List X} → R x y → lex R (x ∷ xs) (y ∷ ys)
 tail-lex : {x y : X}{xs ys : List X} → x ＝ y → lex R xs ys → lex R (x ∷ xs) (y ∷ ys)

lex-for-ordinal : (α : Ordinal 𝓤) → List ⟨ α ⟩ → List ⟨ α ⟩ → 𝓤 ̇
lex-for-ordinal α = lex (underlying-order α)

syntax lex-for-ordinal α xs ys = xs ≺⟨List α ⟩ ys

is-irreflexive : {X : 𝓤 ̇  } (R : X → X → 𝓥 ̇  ) → 𝓤 ⊔ 𝓥 ̇
is-irreflexive R = ∀ x → ¬ (R x x)

module _ {X : 𝓤 ̇  } (R : X → X → 𝓥 ̇  ) where

 lex-transitive : is-transitive R → is-transitive (lex R)
 lex-transitive tr [] (y ∷ ys) (z ∷ zs) []-lex (head-lex q) = []-lex
 lex-transitive tr [] (y ∷ ys) (z ∷ zs) []-lex (tail-lex r q) = []-lex
 lex-transitive tr (x ∷ xs) (y ∷ ys) (z ∷ zs) (head-lex p) (head-lex q) = head-lex (tr x y z p q)
 lex-transitive tr (x ∷ xs) (y ∷ ys) (.y ∷ zs) (head-lex p) (tail-lex refl q) = head-lex p
 lex-transitive tr (x ∷ xs) (.x ∷ ys) (z ∷ zs) (tail-lex refl p) (head-lex q) = head-lex q
 lex-transitive tr (x ∷ xs) (.x ∷ ys) (.x ∷ zs) (tail-lex refl p) (tail-lex refl q)
  = tail-lex refl (lex-transitive tr xs ys zs p q)

 []-lex-bot : is-bot (lex R) []
 []-lex-bot xs ()

 data is-decreasing : List X → 𝓤 ⊔ 𝓥 ̇  where
  []-decr : is-decreasing []
  sing-decr : {x : X} → is-decreasing [ x ]
  many-decr : {x y : X}{xs : List X} → R y x → is-decreasing (y ∷ xs) → is-decreasing (x ∷ y ∷ xs)

 is-decreasing-tail : {x : X} {xs : List X} → is-decreasing (x ∷ xs) → is-decreasing xs
 is-decreasing-tail sing-decr = []-decr
 is-decreasing-tail (many-decr _ d) = d

 is-decreasing-heads : {x y : X} {xs : List X} → is-decreasing (x ∷ y ∷ xs) → R y x
 is-decreasing-heads (many-decr p _) = p

 DecreasingList : (𝓤 ⊔ 𝓥) ̇
 DecreasingList = Σ xs ꞉ List X , is-decreasing xs

 lex-decr : DecreasingList → DecreasingList → 𝓤 ⊔ 𝓥 ̇
 lex-decr (xs , _) (ys , _) = lex R xs ys
\end{code}

\begin{code}
 []-acc-decr : {p : is-decreasing []} → is-accessible lex-decr ([] , p)
 []-acc-decr {[]-decr} = acc (λ xs q → 𝟘-elim ([]-lex-bot _ q))

 lex-decr-acc : is-transitive R
              → (x : X) → is-accessible R x
              → (xs : List X) (δ : is-decreasing xs)
              → is-accessible lex-decr (xs , δ)
              → (ε : is-decreasing (x ∷ xs))
              → is-accessible lex-decr ((x ∷ xs) , ε)
 lex-decr-acc tr =
  transfinite-induction' R P ϕ
    where
     Q : X → DecreasingList → 𝓤 ⊔ 𝓥 ̇
     Q x (xs , _) = (ε' : is-decreasing (x ∷ xs)) → is-accessible lex-decr ((x ∷ xs) , ε')
     P : X → 𝓤 ⊔ 𝓥 ̇
     P x = (xs : List X) (δ : is-decreasing xs)
         → is-accessible lex-decr (xs , δ)
         → Q x (xs , δ)

     ϕ : (x : X) → ((y : X) → R y x → P y) → P x
     ϕ x IH xs δ β = transfinite-induction' lex-decr (Q x) (λ (xs , ε) → ϕ' xs ε) (xs , δ) β
      where
       ϕ' : (xs : List X) → (ε : is-decreasing xs)
          → ((ys : DecreasingList) → lex-decr ys (xs , ε) → Q x ys)
          → Q x (xs , ε)
       ϕ' xs _ IH₂ ε' = acc (λ (ys , ε) → g ys ε)
        where
         g : (ys : List X) → (ε : is-decreasing ys)
            → lex-decr (ys , ε) ((x ∷ xs) , ε')
            → is-accessible lex-decr (ys , ε)
         g [] ε p = []-acc-decr
         g (y ∷ []) ε (head-lex p) = IH y p [] []-decr []-acc-decr ε
         g (y ∷ z ∷ ys) ε (head-lex p) =
           IH y p (z ∷ ys) (is-decreasing-tail ε)
              (g (z ∷ ys) (is-decreasing-tail ε) (head-lex (tr z y x (is-decreasing-heads ε) p)))
              ε
         g (.x ∷ ys) ε (tail-lex refl l) = IH₂ (ys , is-decreasing-tail ε) l ε

 lex-wellfounded : is-transitive R → is-well-founded R → is-well-founded lex-decr
 lex-wellfounded tr wf (xs , δ) = lex-wellfounded' wf xs δ
  where
   lex-wellfounded' : is-well-founded R
                    → (xs : List X) (δ : is-decreasing xs)
                    → is-accessible lex-decr (xs , δ)
   lex-wellfounded' wf [] δ = []-acc-decr
   lex-wellfounded' wf (x ∷ xs) δ =
     lex-decr-acc tr
                  x
                  (wf x)
                  xs
                  (is-decreasing-tail δ)
                  (lex-wellfounded' wf xs (is-decreasing-tail δ))
                  δ
\end{code}

\begin{code}

 lex-irreflexive : is-irreflexive R → is-irreflexive (lex R)
 lex-irreflexive ir (x ∷ xs) (head-lex p) = ir x p
 lex-irreflexive ir (x ∷ xs) (tail-lex e q) = lex-irreflexive ir xs q

 -- this is not helpful below
 lex-extensional : is-irreflexive R → is-extensional R → is-extensional (lex R)
 lex-extensional ir ext [] [] p q = refl
 lex-extensional ir ext [] (y ∷ ys) p q = 𝟘-elim ([]-lex-bot [] (q [] []-lex))
 lex-extensional ir ext (x ∷ xs) [] p q = 𝟘-elim ([]-lex-bot [] (p [] []-lex))
 lex-extensional ir ext (x ∷ xs) (y ∷ ys) p q = ap₂ _∷_ e₀ e₁
  where
   p₀ : ∀ z → R z x → R z y
   p₀ z zRx with (p (z ∷ ys) (head-lex zRx))
   p₀ z zRx | head-lex zRy = zRy
   p₀ z zRx | tail-lex _ ysRys = 𝟘-elim (lex-irreflexive ir ys ysRys)
   q₀ : ∀ z → R z y → R z x
   q₀ z zRy with (q (z ∷ xs) (head-lex zRy))
   q₀ z zRy | head-lex zRx = zRx
   q₀ z zRy | tail-lex _ xsRxs = 𝟘-elim (lex-irreflexive ir xs xsRxs)
   e₀ : x ＝ y
   e₀ = ext x y p₀ q₀
   p₁ : ∀ zs → lex R zs xs → lex R zs ys
   p₁ zs zsRxs with (p (x ∷ zs) (tail-lex refl zsRxs))
   p₁ zs zsRxs | head-lex xRy = 𝟘-elim (ir y (transport (λ z → R z y) e₀ xRy))
   p₁ zs zsRxs | tail-lex _ zsRys = zsRys
   q₁ : ∀ zs → lex R zs ys → lex R zs xs
   q₁ zs zsRys with (q (y ∷ zs) (tail-lex refl zsRys))
   q₁ zs zsRys | head-lex yRx = 𝟘-elim (ir y (transport (λ z → R y z) e₀ yRx))
   q₁ zs zsRys | tail-lex _ zsRxs = zsRxs
   e₁ : xs ＝ ys
   e₁ = lex-extensional ir ext xs ys p₁ q₁

\end{code}

\begin{code}

 lex-prop-valued : is-set X → is-prop-valued R → is-irreflexive R → is-prop-valued (lex R)
 lex-prop-valued st pr irR [] (y ∷ ys) []-lex []-lex = refl
 lex-prop-valued st pr irR (x ∷ xs) (y ∷ ys) (head-lex p) (head-lex q) = ap head-lex (pr x y p q)
 lex-prop-valued st pr irR (.y ∷ xs) (y ∷ ys) (head-lex p) (tail-lex refl qs) = 𝟘-elim (irR y p)
 lex-prop-valued st pr irR (x ∷ xs) (.x ∷ ys) (tail-lex refl ps) (head-lex q) = 𝟘-elim (irR x q)
 lex-prop-valued st pr irR (x ∷ xs) (y ∷ ys) (tail-lex e ps) (tail-lex r qs) =
  ap₂ tail-lex (st e r) (lex-prop-valued st pr irR xs ys ps qs)

\end{code}

\begin{code}


-- can we get away with different universes like this?
module _ (α : Ordinal 𝓤)(β : Ordinal 𝓥) where

 ⟨[𝟙+_]^_⟩ : 𝓤 ⊔ 𝓥 ̇
 ⟨[𝟙+_]^_⟩ = Σ xs ꞉ List ⟨ β ×ₒ α ⟩ , is-decreasing (underlying-order α) (map pr₂ xs)

 underlying-list : ⟨[𝟙+_]^_⟩ → List ⟨ β ×ₒ α ⟩
 underlying-list (xs , _) = xs

 underlying-list-decreasing-base : (xs : ⟨[𝟙+_]^_⟩) → is-decreasing (underlying-order α) (map pr₂ (underlying-list xs))
 underlying-list-decreasing-base (xs , p) = p

 underlying-list-decreasing : (xs : ⟨[𝟙+_]^_⟩) → is-decreasing (underlying-order (β ×ₒ α)) (underlying-list xs)
 underlying-list-decreasing (xs , p) = is-decreasing-pr₂-to-is-decreasing xs p
  where
   is-decreasing-pr₂-to-is-decreasing : (xs : List ⟨ β ×ₒ α ⟩)
                                      → is-decreasing (underlying-order α) (map pr₂ xs)
                                      → is-decreasing (underlying-order (β ×ₒ α)) xs
   is-decreasing-pr₂-to-is-decreasing [] _ = []-decr
   is-decreasing-pr₂-to-is-decreasing (x ∷ []) _ = sing-decr
   is-decreasing-pr₂-to-is-decreasing (x ∷ x' ∷ xs) (many-decr p ps)
    = many-decr (inl p) (is-decreasing-pr₂-to-is-decreasing (x' ∷ xs) ps)

 exponential-order : ⟨[𝟙+_]^_⟩ → ⟨[𝟙+_]^_⟩ → 𝓤 ⊔ 𝓥 ̇
 exponential-order (xs , _) (ys , _) = xs ≺⟨List (β ×ₒ α) ⟩ ys

 exponential-order-prop-valued : is-prop-valued exponential-order
 exponential-order-prop-valued (xs , _) (ys , _)
   = lex-prop-valued _ (underlying-type-is-set fe (β ×ₒ α))
                       (Prop-valuedness (β ×ₒ α))
                       (irrefl (β ×ₒ α))
                       xs
                       ys

 exponential-order-wellfounded : is-well-founded exponential-order
 exponential-order-wellfounded (xs , δ) =
  acc-lex-decr-to-acc-exponential xs δ (lex-wellfounded (underlying-order (β ×ₒ α)) (Transitivity (β ×ₒ α)) (Well-foundedness (β ×ₒ α)) _)
  where
   acc-lex-decr-to-acc-exponential : (xs : List ⟨ β ×ₒ α ⟩)
                                   → (δ : is-decreasing (underlying-order α) (map pr₂ xs))
                                   → is-accessible (lex-decr (underlying-order (β ×ₒ α))) ((xs , underlying-list-decreasing (xs , δ)))
                                   → is-accessible exponential-order (xs , δ)
   acc-lex-decr-to-acc-exponential xs δ (acc h) =
    acc λ (ys , ε) ys<xs → acc-lex-decr-to-acc-exponential ys ε (h (ys ,  underlying-list-decreasing (ys , ε)) ys<xs)

 exponential-order-transitive : is-transitive exponential-order
 exponential-order-transitive (xs , _) (ys , _) (zs , _) p q =
  lex-transitive (underlying-order (β ×ₒ α)) (Transitivity (β ×ₒ α)) xs ys zs p q

[𝟙+_]^_ : Ordinal 𝓤 → Ordinal 𝓥 → Ordinal (𝓤 ⊔ 𝓥)
[𝟙+ α ]^ β = ⟨[𝟙+ α ]^ β ⟩
           , exponential-order α β
           , exponential-order-prop-valued α β
           , exponential-order-wellfounded α β
           , {!!}
           , exponential-order-transitive α β


{-

-}


-- prove that (1 + A) ^ X is an ordinal

-- End goal: prove it satisfies (0, succ, sup)-spec
