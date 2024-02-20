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

open import UF.PropTrunc
open import UF.Size

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

 is-decreasing-propositional : ((x y : X) → is-prop (R x y))
                             → (xs : List X) → is-prop (is-decreasing xs)
 is-decreasing-propositional pR [] []-decr []-decr = refl
 is-decreasing-propositional pR (x ∷ []) sing-decr sing-decr = refl
 is-decreasing-propositional pR (x ∷ y ∷ xs) (many-decr p ps) (many-decr q qs) =
  ap₂ many-decr (pR y x p q) (is-decreasing-propositional pR (y ∷ xs) ps qs)

 is-decreasing-tail : {x : X} {xs : List X} → is-decreasing (x ∷ xs) → is-decreasing xs
 is-decreasing-tail sing-decr = []-decr
 is-decreasing-tail (many-decr _ d) = d

 is-decreasing-heads : {x y : X} {xs : List X} → is-decreasing (x ∷ y ∷ xs) → R y x
 is-decreasing-heads (many-decr p _) = p

 is-decreasing-cons : {y x : X} {xs : List X} → R x y → is-decreasing (x ∷ xs) → is-decreasing (y ∷ x ∷ xs)
 is-decreasing-cons {y} {x} {xs} r δ = many-decr r δ

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

 is-decreasing-pr₂ : List ⟨ α ×ₒ β ⟩ → 𝓥 ̇
 is-decreasing-pr₂ xs = is-decreasing (underlying-order β) (map pr₂ xs)

 ⟨[𝟙+_]^_⟩ : 𝓤 ⊔ 𝓥 ̇
 ⟨[𝟙+_]^_⟩ = Σ xs ꞉ List ⟨ α ×ₒ β ⟩ , is-decreasing-pr₂ xs

 to-exponential-＝ : {xs ys : ⟨[𝟙+_]^_⟩} → pr₁ xs ＝ pr₁ ys → xs ＝ ys
 to-exponential-＝ = to-subtype-＝ (λ xs → is-decreasing-propositional
                                            (underlying-order β)
                                            (Prop-valuedness β)
                                            (map pr₂ xs))



 underlying-list : ⟨[𝟙+_]^_⟩ → List ⟨ α ×ₒ β ⟩
 underlying-list (xs , _) = xs

 underlying-list-decreasing-base : (xs : ⟨[𝟙+_]^_⟩) → is-decreasing-pr₂ (underlying-list xs)
 underlying-list-decreasing-base (xs , p) = p

 underlying-list-decreasing : (xs : ⟨[𝟙+_]^_⟩) → is-decreasing (underlying-order (α ×ₒ β)) (underlying-list xs)
 underlying-list-decreasing (xs , p) = is-decreasing-pr₂-to-is-decreasing xs p
  where
   is-decreasing-pr₂-to-is-decreasing : (xs : List ⟨ α ×ₒ β ⟩)
                                      → is-decreasing-pr₂ xs
                                      → is-decreasing (underlying-order (α ×ₒ β)) xs
   is-decreasing-pr₂-to-is-decreasing [] _ = []-decr
   is-decreasing-pr₂-to-is-decreasing (x ∷ []) _ = sing-decr
   is-decreasing-pr₂-to-is-decreasing (x ∷ x' ∷ xs) (many-decr p ps)
    = many-decr (inl p) (is-decreasing-pr₂-to-is-decreasing (x' ∷ xs) ps)

 exponential-order : ⟨[𝟙+_]^_⟩ → ⟨[𝟙+_]^_⟩ → 𝓤 ⊔ 𝓥 ̇
 exponential-order (xs , _) (ys , _) = xs ≺⟨List (α ×ₒ β) ⟩ ys

 exponential-order-prop-valued : is-prop-valued exponential-order
 exponential-order-prop-valued (xs , _) (ys , _)
   = lex-prop-valued _ (underlying-type-is-set fe (α ×ₒ β))
                       (Prop-valuedness (α ×ₒ β))
                       (irrefl (α ×ₒ β))
                       xs
                       ys

 exponential-order-wellfounded : is-well-founded exponential-order
 exponential-order-wellfounded (xs , δ) =
  acc-lex-decr-to-acc-exponential xs δ (lex-wellfounded (underlying-order (α ×ₒ β)) (Transitivity (α ×ₒ β)) (Well-foundedness (α ×ₒ β)) _)
  where
   acc-lex-decr-to-acc-exponential : (xs : List ⟨ α ×ₒ β ⟩)
                                   → (δ : is-decreasing-pr₂ xs)
                                   → is-accessible (lex-decr (underlying-order (α ×ₒ β))) ((xs , underlying-list-decreasing (xs , δ)))
                                   → is-accessible exponential-order (xs , δ)
   acc-lex-decr-to-acc-exponential xs δ (acc h) =
    acc λ (ys , ε) ys<xs → acc-lex-decr-to-acc-exponential ys ε (h (ys ,  underlying-list-decreasing (ys , ε)) ys<xs)

 private
  R = underlying-order (α ×ₒ β)

 -- TODO: CLEAN UP
 -- TODO: Rename
 lemma' : (xs ys : List ⟨ α ×ₒ β ⟩) (x : ⟨ α ×ₒ β ⟩)
        → is-decreasing-pr₂ (x ∷ xs)
        → is-decreasing-pr₂ ys
        → lex R ys xs
        → is-decreasing-pr₂ (x ∷ ys)
 lemma' (x' ∷ xs) [] x δ ε l = sing-decr
 lemma' (x' ∷ xs) (y ∷ ys) x (many-decr l δ) ε (head-lex (inl k)) =
  many-decr (Transitivity β (pr₂ y) (pr₂ x') (pr₂ x) k l) ε
 lemma' ((x₁' , _) ∷ xs) ((y₁ , y₂) ∷ ys) (x₁ , x₂) δ ε (head-lex (inr (refl , k))) =
  many-decr (is-decreasing-heads (underlying-order β) δ) ε
 lemma' (_ ∷ xs) (y ∷ ys) x δ ε (tail-lex refl l) =
  many-decr (is-decreasing-heads (underlying-order β) δ) ε

 -- TODO: Rename
 lemma : (xs ys : List ⟨ α ×ₒ β ⟩) (x : ⟨ α ×ₒ β ⟩)
       → is-decreasing-pr₂ (x ∷ xs) → is-decreasing-pr₂ (x ∷ ys)
       → ((zs : List ⟨ α ×ₒ β ⟩)
              → is-decreasing-pr₂ zs
              → lex R zs (x ∷ xs) → lex R zs (x ∷ ys)) -- TODO: Use ≤
       → ((zs : List ⟨ α ×ₒ β ⟩)
              → is-decreasing-pr₂ zs
              → lex R zs xs → lex R zs ys) -- TODO: Use ≤
 lemma xs ys x δ ε h zs ε' l = g hₓ
  where
   hₓ : lex R (x ∷ zs) (x ∷ ys)
   hₓ = h (x ∷ zs) lem (tail-lex refl l)
    where
     lem : is-decreasing-pr₂ (x ∷ zs)
     lem = lemma' xs zs x δ ε' l
   g : lex R (x ∷ zs) (x ∷ ys) → lex R zs ys
   g (head-lex r) = 𝟘-elim (irreflexive R x (Well-foundedness (α ×ₒ β) x) r)
   g (tail-lex _ k) = k


 exponential-order-extensional : is-extensional exponential-order
 exponential-order-extensional (xs , δ) (ys , ε) p q =
  to-exponential-＝ (exponential-order-extensional' xs δ ys ε (λ zs ε' → p (zs , ε')) (λ zs ε' → q (zs , ε')))
  where
   exponential-order-extensional' : (xs : List ⟨ α ×ₒ β ⟩)
                                  → (δ : is-decreasing-pr₂ xs)
                                  → (ys : List ⟨ α ×ₒ β ⟩)
                                  → (ε : is-decreasing-pr₂ ys)
                                  → ((zs : List ⟨ α ×ₒ β ⟩) → is-decreasing-pr₂ zs → lex R zs xs → lex R zs ys )
                                  → ((zs : List ⟨ α ×ₒ β ⟩) → is-decreasing-pr₂ zs → lex R zs ys → lex R zs xs )
                                  → xs ＝ ys
   exponential-order-extensional' [] δ [] ε p q = refl
   exponential-order-extensional' [] δ (y ∷ ys) ε p q =
    𝟘-elim ([]-lex-bot _ [] (q [] δ []-lex))
   exponential-order-extensional' (x ∷ xs) δ [] ε p q =
    𝟘-elim ([]-lex-bot _ [] (p [] ε []-lex))
   exponential-order-extensional' (x ∷ []) δ (y ∷ []) ε p q =
     ap [_] (Extensionality (α ×ₒ β) x y e₁ e₂)
      where
       e₁ : ∀ z → R z x → R z y
       e₁ z r = h p'
        where
         h : lex R [ z ] [ y ] → R z y
         h (head-lex r') = r'
         p' : lex R [ z ] [ y ]
         p' = p [ z ] sing-decr (head-lex r)
       e₂ : ∀ z → R z y → R z x
       e₂ z r = h q'
        where
         h : lex R [ z ] [ x ] → R z x
         h (head-lex r') = r'
         q' : lex R [ z ] [ x ]
         q' = q [ z ] sing-decr (head-lex r)
   exponential-order-extensional' (x ∷ []) δ (y ∷ y' ∷ ys) ε p q = V
    where
     I : lex R [ y ] (y ∷ y' ∷ ys)
     I = tail-lex refl []-lex
     II : R y x
     II = h q'
      where
       h : lex R [ y ] [ x ] → R y x
       h (head-lex r) = r
       q' : lex R [ y ] [ x ]
       q' = q [ y ] sing-decr I
     III : lex R (y ∷ y' ∷ ys) [ x ]
     III = head-lex II
     IV : lex R (y ∷ y' ∷ ys) (y ∷ y' ∷ ys)
     IV = p (y ∷ y' ∷ ys) ε III
     V : [ x ] ＝ y ∷ y' ∷ ys
     V = 𝟘-elim
          (lex-irreflexive R
            (λ x → irreflexive R x (Well-foundedness (α ×ₒ β) x))
           (y ∷ y' ∷ ys) IV)
   exponential-order-extensional' (x ∷ x' ∷ xs) δ (y ∷ []) ε p q = V -- TODO: Factor out
    where
     I : lex R [ x ] (x ∷ x' ∷ xs)
     I = tail-lex refl []-lex
     II : R x y
     II = h p'
      where
       h : lex R [ x ] [ y ] → R x y
       h (head-lex r) = r
       p' : lex R [ x ] [ y ]
       p' = p [ x ] sing-decr I
     III : lex R (x ∷ x' ∷ xs) [ y ]
     III = head-lex II
     IV : lex R (x ∷ x' ∷ xs) (x ∷ x' ∷ xs)
     IV = q (x ∷ x' ∷ xs) δ III
     V : x ∷ x' ∷ xs ＝ [ y ]
     V = 𝟘-elim
          (lex-irreflexive R
            (λ y → irreflexive R y (Well-foundedness (α ×ₒ β) y))
           (x ∷ x' ∷ xs) IV)
   exponential-order-extensional' (x ∷ x' ∷ xs) δ (y ∷ y' ∷ ys) ε p q =
    ap₂ _∷_ e
            (exponential-order-extensional'
             (x' ∷ xs) (is-decreasing-tail (underlying-order β) δ)
             (y' ∷ ys) (is-decreasing-tail (underlying-order β) ε)
             (p' e) (q' e))
     where
      e : x ＝ y
      e = g II II'
       where
        I : lex R [ x ] (x ∷ x' ∷ xs)
        I = tail-lex refl []-lex
        II : lex R [ x ] (y ∷ y' ∷ ys)
        II = p [ x ] sing-decr I
        I' : lex R [ y ] (y ∷ y' ∷ ys)
        I' = tail-lex refl []-lex
        II' : lex R [ y ] (x ∷ x' ∷ xs)
        II' = q [ y ] sing-decr I'
        g : lex R [ x ] (y ∷ y' ∷ ys)
          → lex R [ y ] (x ∷ x' ∷ xs)
          → x ＝ y
        g (head-lex r) (head-lex r') =
         𝟘-elim (irreflexive R x (Well-foundedness (α ×ₒ β) x) (Transitivity (α ×ₒ β) x y x r r'))
        g (head-lex _) (tail-lex eq _) = eq ⁻¹
        g (tail-lex eq _) _ = eq
      p' : (x ＝ y) → (zs : List ⟨ α ×ₒ β ⟩)
         → is-decreasing-pr₂ zs
         → lex R zs (x' ∷ xs)
         → lex R zs (y' ∷ ys)
      p' refl = lemma (x' ∷ xs) (y' ∷ ys) x δ ε p
      q' : (x ＝ y) → (zs : List ⟨ α ×ₒ β ⟩)
         → is-decreasing-pr₂ zs
         → lex R zs (y' ∷ ys)
         → lex R zs (x' ∷ xs)
      q' refl = lemma (y' ∷ ys) (x' ∷ xs) y ε δ q


 exponential-order-transitive : is-transitive exponential-order
 exponential-order-transitive (xs , _) (ys , _) (zs , _) p q =
  lex-transitive (underlying-order (α ×ₒ β)) (Transitivity (α ×ₒ β)) xs ys zs p q

[𝟙+_]^_ : Ordinal 𝓤 → Ordinal 𝓥 → Ordinal (𝓤 ⊔ 𝓥)
[𝟙+ α ]^ β = ⟨[𝟙+ α ]^ β ⟩
           , exponential-order α β
           , exponential-order-prop-valued α β
           , exponential-order-wellfounded α β
           , exponential-order-extensional α β
           , exponential-order-transitive α β

-- End goal: prove it satisfies (0, succ, sup)-spec

exp-0-spec' : (α : Ordinal 𝓤) → ([𝟙+ α ]^ (𝟘ₒ {𝓥})) ≃ₒ 𝟙ₒ {𝓤 ⊔ 𝓥}
exp-0-spec' α = f , f-monotone , qinvs-are-equivs f f-qinv , g-monotone
 where
  f : ⟨ [𝟙+ α ]^ 𝟘ₒ ⟩ → 𝟙
  f _ = ⋆
  f-monotone : is-order-preserving ([𝟙+ α ]^ 𝟘ₒ) 𝟙ₒ (λ _ → ⋆)
  f-monotone ([] , δ) ([] , ε) u =
    𝟘-elim
     (irreflexive
      (exponential-order α 𝟘ₒ)
      ([] , δ)
      (exponential-order-wellfounded α 𝟘ₒ _) u)
  g : 𝟙 → ⟨ [𝟙+ α ]^ 𝟘ₒ ⟩
  g _ = [] , []-decr
  g-monotone : is-order-preserving 𝟙ₒ ([𝟙+ α ]^ 𝟘ₒ) g
  g-monotone ⋆ ⋆ u = 𝟘-elim u
  f-qinv : qinv f
  f-qinv = g , p , q
   where
    p : (λ x → [] , []-decr) ∼ id
    p ([] , δ) = to-exponential-＝ α 𝟘ₒ refl
    q : (λ x → ⋆) ∼ id
    q ⋆ = refl

exp-0-spec : (α : Ordinal 𝓤) → [𝟙+ α ]^ (𝟘ₒ {𝓥}) ＝ 𝟙ₒ
exp-0-spec {𝓤} {𝓥} α = eqtoidₒ (ua (𝓤 ⊔ 𝓥)) fe' ([𝟙+ α ]^ 𝟘ₒ) 𝟙ₒ (exp-0-spec' α)

exp-+-distributes' : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
                   → ([𝟙+ α ]^ (β +ₒ γ)) ≃ₒ (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ))
exp-+-distributes' α β γ = f , f-monotone , qinvs-are-equivs f f-qinv , g-monotone
 where

  f₀₀ : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → List ⟨ α ×ₒ β ⟩
  f₀₀ [] = []
  f₀₀ ((a , inl b) ∷ xs) = (a , b) ∷ f₀₀ xs
  f₀₀ ((a , inr c) ∷ xs) = f₀₀ xs

  f₁₀ : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → List ⟨ α ×ₒ γ ⟩
  f₁₀ [] = []
  f₁₀ ((a , inl b) ∷ xs) = f₁₀ xs
  f₁₀ ((a , inr c) ∷ xs) = (a , c) ∷ f₁₀ xs

  f₀₁ : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → (δ : is-decreasing-pr₂ α (β +ₒ γ) xs) → is-decreasing-pr₂ α β (f₀₀ xs)
  f₀₁ [] δ = []-decr
  f₀₁ ((a , inl b) ∷ []) δ = sing-decr
  f₀₁ ((a , inl b) ∷ (a' , inl b') ∷ xs) (many-decr p δ) = many-decr p (f₀₁ ((a' , inl b') ∷ xs) δ)
  f₀₁ ((a , inl b) ∷ (a' , inr c) ∷ xs) (many-decr p δ) = 𝟘-elim p
  f₀₁ ((a , inr c) ∷ []) δ = []-decr
  f₀₁ ((a , inr c) ∷ (a' , inl b') ∷ xs) (many-decr ⋆ δ) = f₀₁ ((a' , inl b') ∷ xs) δ
  f₀₁ ((a , inr c) ∷ (a' , inr c') ∷ xs) (many-decr p δ) = f₀₁ xs (is-decreasing-tail (underlying-order (β +ₒ γ)) δ)

  no-swapping-lemma : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → (a : ⟨ α ⟩) → (b : ⟨ β ⟩)
                    → (δ : is-decreasing-pr₂ α (β +ₒ γ) ((a , inl b) ∷ xs))
                    → f₁₀ ((a , inl b) ∷ xs) ＝ []
  no-swapping-lemma [] a b δ = refl
  no-swapping-lemma ((a' , inl b') ∷ xs) a b (many-decr p δ) = no-swapping-lemma xs a b' δ
  no-swapping-lemma ((a' , inr c) ∷ xs) a b (many-decr p δ) = 𝟘-elim p

  f₁₁ : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → (δ : is-decreasing-pr₂ α (β +ₒ γ) xs) → is-decreasing-pr₂ α γ (f₁₀ xs)
  f₁₁ [] δ = []-decr
  f₁₁ ((a , inl b) ∷ []) δ = []-decr
  f₁₁ ((a , inl b) ∷ (a' , inl b') ∷ xs) (many-decr p δ) = f₁₁ xs (is-decreasing-tail (underlying-order (β +ₒ γ)) δ)
  f₁₁ ((a , inl b) ∷ (a' , inr c) ∷ xs) (many-decr p δ) = 𝟘-elim p
  f₁₁ ((a , inr c) ∷ []) δ = sing-decr
  f₁₁ ((a , inr c) ∷ (a' , inl b) ∷ xs) (many-decr ⋆ δ) =
   transport⁻¹ (λ z → is-decreasing-pr₂ α γ ((a , c) ∷ z)) (no-swapping-lemma xs a b δ) sing-decr
  f₁₁ ((a , inr c) ∷ (a' , inr c') ∷ xs) (many-decr p δ) = many-decr p (f₁₁ ((a' , inr c') ∷ xs) δ)

  f₀ : ⟨ [𝟙+ α ]^ (β +ₒ γ) ⟩ → ⟨ [𝟙+ α ]^ β ⟩
  f₀ (xs , δ) = (f₀₀ xs) , (f₀₁ xs δ)

  f₁ : ⟨ [𝟙+ α ]^ (β +ₒ γ) ⟩ → ⟨ [𝟙+ α ]^ γ ⟩
  f₁ (xs , δ) = (f₁₀ xs) , (f₁₁ xs δ)

  f : ⟨ [𝟙+ α ]^ (β +ₒ γ) ⟩ → ⟨ ([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ) ⟩
  f (xs , δ) = (f₀ (xs , δ) , f₁ (xs , δ))


  f-monotone : is-order-preserving ([𝟙+ α ]^ (β +ₒ γ)) (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) f
  f-monotone ([] , δ) (((a , inl b) ∷ ys) , ε) []-lex = inr (to-exponential-＝ α γ (no-swapping-lemma ys a b ε ⁻¹) , []-lex)
  f-monotone ([] , δ) (((a , inr c) ∷ ys) , ε) []-lex = inl []-lex
  f-monotone (((a , inl b) ∷ xs) , δ) (((a' , inl b') ∷ ys) , ε) (head-lex (inl p)) =
   inr (to-exponential-＝ α γ (no-swapping-lemma xs a b δ ∙ no-swapping-lemma ys a' b' ε ⁻¹) , head-lex (inl p))
  f-monotone (((a , inl b) ∷ xs) , δ) (((a' , inl b') ∷ ys) , ε) (head-lex (inr (refl , p))) =
   inr (to-exponential-＝ α γ (no-swapping-lemma xs a b δ ∙ no-swapping-lemma ys a' b ε ⁻¹) , (head-lex (inr (refl , p))))
  f-monotone (((a , inl b) ∷ xs) , δ) (((a , inl b) ∷ ys) , ε) (tail-lex refl ps) =
    h (f-monotone (xs , is-decreasing-tail (underlying-order (β +ₒ γ)) δ) (ys , is-decreasing-tail (underlying-order (β +ₒ γ)) ε) ps)
   where
    h : underlying-order (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) (f (xs , is-decreasing-tail _ δ)) (f (ys , is-decreasing-tail _ ε))
      → underlying-order (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) (f (((a , inl b) ∷ xs) , δ)) (f (((a , inl b) ∷ ys) , ε))
    h (inl p) = 𝟘-elim (irrefl ([𝟙+ α ]^ γ)
                               ([] , []-decr)
                               (transport₂ (exponential-order α γ)
                                           {x = f₁₀ xs , f₁₁ xs (is-decreasing-tail (underlying-order (β +ₒ γ)) δ)}
                                           {x' = [] , []-decr}
                                           {y = f₁₀ ys , f₁₁ ys (is-decreasing-tail (underlying-order (β +ₒ γ)) ε)}
                                           {y' = [] , []-decr}
                                           (to-exponential-＝ α γ (no-swapping-lemma xs a b δ))
                                           (to-exponential-＝ α γ (no-swapping-lemma ys a b ε)) p))
    h (inr (r , p)) = inr ((to-exponential-＝ α γ (ap pr₁ r)) , tail-lex refl p)
  f-monotone (((a , inr c) ∷ xs) , δ) (((a' , inr c') ∷ ys) , ε) (head-lex (inl p)) = inl (head-lex (inl p))
  f-monotone (((a , inr c) ∷ xs) , δ) (((a' , inr c) ∷ ys) , ε) (head-lex (inr (refl , p))) = inl (head-lex (inr (refl , p)))
  f-monotone (((a , inr c) ∷ xs) , δ) (((a , inr c) ∷ ys) , ε) (tail-lex refl ps) =
   h (f-monotone (xs , is-decreasing-tail (underlying-order (β +ₒ γ)) δ) (ys , is-decreasing-tail (underlying-order (β +ₒ γ)) ε) ps)
   where
    h : underlying-order (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) (f (xs , is-decreasing-tail _ δ)) (f (ys , is-decreasing-tail _ ε))
      → underlying-order (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) (f (((a , inr c) ∷ xs) , δ)) (f (((a , inr c) ∷ ys) , ε))
    h (inl p) = inl (tail-lex refl p)
    h (inr (r , p)) = inr (to-exponential-＝ α γ (ap ((a , c) ∷_) (ap pr₁ r)) , p)
  f-monotone (((a , inl b) ∷ xs) , δ) (((a' , inr c') ∷ ys) , ε) (head-lex (inl ⋆)) =
   inl (transport⁻¹ (λ z → lex (underlying-order (α ×ₒ γ)) z ((a' , c') ∷ _)) (no-swapping-lemma xs a b δ) []-lex)
  f-monotone (((a , inl b) ∷ xs) , δ) (((a' , inr c') ∷ ys) , ε) (tail-lex p ps) = 𝟘-elim (+disjoint (ap pr₂ p))
  f-monotone (((a , inr c) ∷ xs) , δ) (((a' , inl b') ∷ ys) , ε) (head-lex (inr (r , p))) = 𝟘-elim (+disjoint (r ⁻¹))
  f-monotone (((a , inr c) ∷ xs) , δ) (((a' , inl b') ∷ ys) , ε) (tail-lex p ps) = 𝟘-elim (+disjoint (ap pr₂ p ⁻¹))

  g₀ : (bs : List ⟨ α ×ₒ β ⟩) → (cs : List ⟨ α ×ₒ γ ⟩) → List ⟨ α ×ₒ (β +ₒ γ) ⟩
  g₀ bs ((a , c) ∷ cs) = (a , inr c) ∷ g₀ bs cs
  g₀ ((a , b) ∷ bs) [] = (a , inl b) ∷ g₀ bs []
  g₀ [] [] = []

  g₁ : (bs : List ⟨ α ×ₒ β ⟩) → is-decreasing-pr₂ α β bs
     → (cs : List ⟨ α ×ₒ γ ⟩) → is-decreasing-pr₂ α γ cs
     → is-decreasing-pr₂ α (β +ₒ γ) (g₀ bs cs)
  g₁ [] δ (a , c ∷ []) ε = sing-decr
  g₁ ((a , b) ∷ bs) δ ((a' , c) ∷ []) ε = many-decr ⋆ (g₁ ((a , b) ∷ bs) δ [] []-decr)
  g₁ bs δ ((a , c) ∷ (a' , c') ∷ cs) ε =
   many-decr (is-decreasing-heads (underlying-order γ) ε)
             (g₁ bs δ ((a' , c') ∷ cs) (is-decreasing-tail (underlying-order γ) ε))
  g₁ [] δ [] ε = []-decr
  g₁ (x ∷ []) δ [] ε = sing-decr
  g₁ ((a , b) ∷ (a' , b') ∷ bs) δ [] ε =
   many-decr (is-decreasing-heads (underlying-order β) δ)
             (g₁ ((a' , b') ∷ bs) (is-decreasing-tail (underlying-order β) δ) [] ε)

  g : ⟨ ([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ) ⟩ → ⟨ [𝟙+ α ]^ (β +ₒ γ) ⟩
  g ((bs , δ) , (cs , ε)) = g₀ bs cs , g₁ bs δ cs ε

  g₀-monotone : (bs : List ⟨ α ×ₒ β ⟩) → (δ : is-decreasing-pr₂ α β bs)
              → (cs : List ⟨ α ×ₒ γ ⟩) → (ε : is-decreasing-pr₂ α γ cs)
              → (bs' : List ⟨ α ×ₒ β ⟩) → (δ' : is-decreasing-pr₂ α β bs')
              → (cs' : List ⟨ α ×ₒ γ ⟩) → (ε' : is-decreasing-pr₂ α γ cs')
              → lex (underlying-order (α ×ₒ γ)) cs cs' + (((cs , ε) ＝ (cs' , ε')) × lex (underlying-order (α ×ₒ β)) bs bs')
              → g₀ bs cs ≺⟨List (α ×ₒ (β +ₒ γ)) ⟩ g₀ bs' cs'
  g₀-monotone [] δ [] ε [] δ' [] ε' (inl p) = 𝟘-elim (irrefl ([𝟙+ α ]^ γ) ([] , []-decr) p)
  g₀-monotone [] δ [] ε [] δ' [] ε' (inr (r , p)) = 𝟘-elim (irrefl ([𝟙+ α ]^ β) ([] , []-decr) p)
  g₀-monotone [] δ [] ε ((a' , b') ∷ bs') δ' [] ε' p = []-lex
  g₀-monotone [] δ [] ε bs' δ' ((a' , c') ∷ cs') ε' p = []-lex
  g₀-monotone [] δ (a , c ∷ cs) ε [] δ' [] ε' (inr (r , p)) = 𝟘-elim (irrefl ([𝟙+ α ]^ β) ([] , []-decr) p)
  g₀-monotone [] δ (a , c ∷ cs) ε (a' , b' ∷ bs') δ' [] ε' (inr (r , p)) = 𝟘-elim ([]-is-not-cons (a , c) cs (ap pr₁ r ⁻¹ ))
  g₀-monotone [] δ (a , c ∷ cs) ε bs' δ' (a' , c' ∷ cs') ε' (inl (head-lex (inl p))) = head-lex (inl p)
  g₀-monotone [] δ (a , c ∷ cs) ε bs' δ' (a' , c' ∷ cs') ε' (inl (head-lex (inr (r , p)))) = head-lex (inr ((ap inr r) , p))
  g₀-monotone [] δ (a , c ∷ cs) ε bs' δ' (a , c ∷ cs') ε' (inl (tail-lex refl ps)) =
   tail-lex refl (g₀-monotone [] δ cs (is-decreasing-tail (underlying-order γ) ε) bs' δ' cs' (is-decreasing-tail (underlying-order γ) ε') (inl ps))
  g₀-monotone [] δ (a , c ∷ cs) ε bs' δ' (a , c ∷ cs) ε (inr (refl , p)) =
   tail-lex refl (g₀-monotone [] δ cs (is-decreasing-tail (underlying-order γ) ε) bs' δ' cs (is-decreasing-tail (underlying-order γ) ε) (inr (refl , p)))
  g₀-monotone (a , b ∷ bs) δ [] ε [] δ' [] ε' (inl p) = 𝟘-elim (irrefl ([𝟙+ α ]^  γ) ([] , []-decr) p)
  g₀-monotone (a , b ∷ bs) δ [] ε (a' , b' ∷ bs') δ' [] ε' (inr (_ , head-lex (inl p))) = head-lex (inl p)
  g₀-monotone (a , b ∷ bs) δ [] ε (a' , b ∷ bs') δ' [] ε' (inr (_ , head-lex (inr (refl , p)))) = head-lex (inr (refl , p))
  g₀-monotone (a , b ∷ bs) δ [] ε (a , b ∷ bs') δ' [] ε' (inr (_ , tail-lex refl ps)) =
   tail-lex refl (g₀-monotone bs (is-decreasing-tail (underlying-order β) δ) [] []-decr bs' (is-decreasing-tail (underlying-order β) δ') [] []-decr (inr (refl , ps)) )
  g₀-monotone (a , b ∷ bs) δ [] ε bs' δ' ((a' , c') ∷ cs') ε' p = head-lex (inl ⋆)
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε [] δ' [] ε' (inl p) = 𝟘-elim ([]-lex-bot (underlying-order  (α ×ₒ γ)) ((a' , c) ∷ cs) p)
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε ((a'' , b') ∷ bs') δ' [] ε' (inl p) = 𝟘-elim ([]-lex-bot (underlying-order  (α ×ₒ γ)) ((a' , c) ∷ cs) p)
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε bs' δ' (a'' , c' ∷ cs') ε' (inl (head-lex (inl p))) = head-lex (inl p)
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε bs' δ' (a'' , c' ∷ cs') ε' (inl (head-lex (inr (r , p)))) = head-lex (inr ((ap inr r) , p))
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε bs' δ' (a' , c ∷ cs') ε' (inl (tail-lex refl ps)) =
   tail-lex refl (g₀-monotone ((a , b) ∷ bs) δ cs (is-decreasing-tail (underlying-order γ) ε) bs' δ' cs' (is-decreasing-tail (underlying-order γ) ε') (inl ps))
  g₀-monotone (a , b ∷ bs) δ (a' , c ∷ cs) ε bs' δ' (a' , c ∷ cs) ε (inr (refl , p)) =
   tail-lex refl (g₀-monotone ((a , b) ∷ bs) δ cs (is-decreasing-tail (underlying-order γ) ε) bs' δ' cs (is-decreasing-tail (underlying-order γ) ε) (inr (refl , p)))

  g-monotone : is-order-preserving (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) ([𝟙+ α ]^ (β +ₒ γ)) g
  g-monotone ((bs , δ) , (cs , ε)) ((bs' , δ') , (cs' , ε')) p = g₀-monotone bs δ cs ε bs' δ' cs' ε' p

  f-qinv : qinv f
  f-qinv = g , p , q
   where
    p₀ : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → is-decreasing-pr₂ α (β +ₒ γ) xs → g₀ (f₀₀ xs) (f₁₀ xs) ＝ xs
    p₀ [] δ = refl
    p₀ (a , inl b ∷ []) δ = refl
    p₀ (a , inl b ∷ xs) δ =
     transport⁻¹ (λ z → g₀ ((a , b) ∷ f₀₀ xs) z ＝ (a , inl b) ∷ xs) (no-swapping-lemma xs a b δ) (ap ((a , inl b) ∷_) (p₀-[] xs (no-inr (map pr₂ xs) b δ)))
     where
      p₀-[] : (xs : List ⟨ α ×ₒ (β +ₒ γ) ⟩) → ((c : ⟨ γ ⟩) → ¬ member (inr c) (map pr₂ xs) ) → g₀ (f₀₀ xs) [] ＝ xs
      p₀-[] [] p = refl
      p₀-[] ((a , inl b) ∷ xs) p = ap ((a , inl b) ∷_) (p₀-[] xs (λ c q → p c (in-tail q)))
      p₀-[] ((a , inr c) ∷ xs) p = 𝟘-elim (p c in-head)

      no-inr : (xs : List ⟨ β +ₒ γ ⟩)(b : ⟨ β ⟩) → is-decreasing (underlying-order (β +ₒ γ)) (inl b ∷ xs) → (c : ⟨ γ ⟩) → ¬ member (inr c) xs
      no-inr (inr c ∷ xs) b δ c in-head = 𝟘-elim (is-decreasing-heads (underlying-order (β +ₒ γ)) δ)
      no-inr (inl b' ∷ xs) b δ c (in-tail p) = no-inr xs b' (is-decreasing-tail (underlying-order (β +ₒ γ)) δ) c p
      no-inr (inr c' ∷ xs) b δ c (in-tail p) = 𝟘-elim (is-decreasing-heads (underlying-order (β +ₒ γ)) δ)
    p₀ ((a , inr c) ∷ xs) δ = ap ((a , inr c) ∷_) (p₀ xs (is-decreasing-tail (underlying-order (β +ₒ γ)) δ))

    p : (g ∘ f) ∼ id
    p (xs , δ) = to-exponential-＝ α (β +ₒ γ) (p₀ xs δ)

    q₀₀ : (bs : List ⟨ α ×ₒ β ⟩) → (cs : List ⟨ α ×ₒ γ ⟩) → f₀₀ (g₀ bs cs) ＝ bs
    q₀₀ bs ((a , c) ∷ cs) = q₀₀ bs cs
    q₀₀ ((a , b) ∷ bs) [] = ap ((a , b) ∷_) (q₀₀ bs [])
    q₀₀ [] [] = refl

    q₁₀ : (bs : List ⟨ α ×ₒ β ⟩) → (cs : List ⟨ α ×ₒ γ ⟩) → f₁₀ (g₀ bs cs) ＝ cs
    q₁₀ bs ((a , c) ∷ cs) = ap ((a , c) ∷_) (q₁₀ bs cs)
    q₁₀ ((a , b) ∷ bs) [] = q₁₀ bs []
    q₁₀ [] [] = refl

    q : (f ∘ g) ∼ id
    q ((bs , δ) , (cs , ε)) = to-×-＝ (to-exponential-＝ α β (q₀₀ bs cs)) (to-exponential-＝ α γ (q₁₀ bs cs))

exp-+-distributes : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
                  → ([𝟙+ α ]^ (β +ₒ γ)) ＝ (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ))
exp-+-distributes {𝓤} {𝓥} α β γ =
 eqtoidₒ (ua (𝓤 ⊔ 𝓥)) fe' ([𝟙+ α ]^ (β +ₒ γ)) (([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ γ)) (exp-+-distributes' α β γ)

exp-power-1' : (α : Ordinal 𝓤) → ([𝟙+ α ]^ 𝟙ₒ {𝓥}) ≃ₒ (𝟙ₒ +ₒ α)
exp-power-1' α = f , f-monotone , qinvs-are-equivs f f-qinv , g-monotone
 where
  f : ⟨ [𝟙+ α ]^ 𝟙ₒ {𝓤} ⟩ → ⟨ 𝟙ₒ +ₒ α ⟩
  f ([] , δ) = inl ⋆
  f (((a , ⋆) ∷ []) , δ) = inr a
  f (((a , ⋆) ∷ (a' , ⋆) ∷ xs) , many-decr p δ) = 𝟘-elim (irrefl 𝟙ₒ ⋆ p)
  f-monotone : is-order-preserving ([𝟙+ α ]^ 𝟙ₒ {𝓤}) (𝟙ₒ +ₒ α) f
  f-monotone ([] , δ) ([] , ε) q = 𝟘-elim (irrefl ([𝟙+ α ]^ 𝟙ₒ) ([] , δ) q)
  f-monotone ([] , δ) ((y ∷ []) , ε) q = ⋆
  f-monotone ([] , δ) (((a , ⋆) ∷ (a' , ⋆) ∷ ys) , many-decr p ε) q = 𝟘-elim (irrefl 𝟙ₒ ⋆ p)
  f-monotone (((a , ⋆) ∷ []) , δ) (((a' , ⋆) ∷ []) , ε) (head-lex (inr (r , q))) = q
  f-monotone (((a , ⋆) ∷ []) , δ) (((a' , ⋆) ∷ (a'' , ⋆) ∷ ys) , many-decr p ε) q = 𝟘-elim (irrefl 𝟙ₒ ⋆ p)
  f-monotone (((a , ⋆) ∷ (a' , ⋆) ∷ xs) , many-decr p δ) (ys , ε) q = 𝟘-elim (irrefl 𝟙ₒ ⋆ p)
  g : ⟨ 𝟙ₒ +ₒ α ⟩ → ⟨ [𝟙+ α ]^ 𝟙ₒ {𝓤} ⟩
  g (inl ⋆) = ([] , []-decr)
  g (inr a) = ([ a , ⋆ ] , sing-decr)
  g-monotone : is-order-preserving (𝟙ₒ +ₒ α) ([𝟙+ α ]^ 𝟙ₒ {𝓤}) g
  g-monotone (inl ⋆) (inr a) ⋆ = []-lex
  g-monotone (inr a) (inr a') p = head-lex (inr (refl , p))
  f-qinv : qinv f
  f-qinv = g , p , q
   where
    p : (g ∘ f) ∼ id
    p ([] , δ) = to-exponential-＝ α 𝟙ₒ refl
    p (((a , ⋆) ∷ []) , δ) = to-exponential-＝ α 𝟙ₒ refl
    p (((a , ⋆) ∷ (a' , ⋆) ∷ xs) , many-decr p δ) = 𝟘-elim (irrefl 𝟙ₒ ⋆ p)
    q : (f ∘ g) ∼ id
    q (inl ⋆) = refl
    q (inr a) = refl

exp-power-1 : {𝓤 : Universe} → (α : Ordinal 𝓤) → ([𝟙+ α ]^ 𝟙ₒ) ＝ 𝟙ₒ +ₒ α
exp-power-1 {𝓤} α = eqtoidₒ (ua 𝓤) fe' ([𝟙+ α ]^ 𝟙ₒ {𝓤}) (𝟙ₒ +ₒ α) (exp-power-1' α)

exp-succ-spec : (α : Ordinal 𝓤) (β : Ordinal 𝓤)
              → ([𝟙+ α ]^ (β +ₒ 𝟙ₒ)) ＝ (([𝟙+ α ]^ β) ×ₒ (𝟙ₒ +ₒ α))
exp-succ-spec {𝓤} α β =
  [𝟙+ α ]^ (β +ₒ 𝟙ₒ)
   ＝⟨ exp-+-distributes α β 𝟙ₒ ⟩
  ([𝟙+ α ]^ β) ×ₒ ([𝟙+ α ]^ 𝟙ₒ)
   ＝⟨ ap (λ z → ([𝟙+ α ]^ β) ×ₒ z) (exp-power-1 α) ⟩
  ([𝟙+ α ]^ β) ×ₒ (𝟙ₒ +ₒ α)
   ∎

\end{code}

\begin{code}

{-

(1 + α)^(⋁ᵢ βᵢ)

= Σ l : List (α × ⋁ᵢ βᵢ) , decreasing-pr2 l
= Σ l : List (⋁ᵢ (α × βᵢ)) , ...
?= ⋁ᵢ (Σ l : List (α × βᵢ) , decreasing-pr2 l)
= ⋁ᵢ (1 + α)^β


(1) Try for general families
(1.5) Try for monotone families
(2) Try for (x ↦ α ↓ x) for α an ordinal

-}

order-reflecting-and-partial-inverse-is-initial-segment : (α β : Ordinal 𝓤)
                                                       (f : ⟨ α ⟩ → ⟨ β ⟩)
                                                     → is-order-reflecting α β f
                                                     → ((a : ⟨ α ⟩)(b : ⟨ β ⟩) → b ≺⟨ β ⟩ f a → Σ a' ꞉ ⟨ α ⟩ , f a' ＝ b)
                                                     → is-initial-segment α β f
order-reflecting-and-partial-inverse-is-initial-segment α β f p i a b m = a' , p' , q'
  where
    q : Σ a' ꞉ ⟨ α ⟩ , f a' ＝ b
    q = i a b m
    a' : ⟨ α ⟩
    a' = pr₁ q
    q' : f a' ＝ b
    q' = pr₂ q

    m' : f a' ≺⟨ β ⟩ f a
    m' = transport⁻¹ (λ - → - ≺⟨ β ⟩ f a) q' m
    p' : a' ≺⟨ α ⟩ a
    p' = p a' a m'

module _ (pt : propositional-truncations-exist)
         (sr : Set-Replacement pt)
       where

 open PropositionalTruncation pt

 open import Ordinals.OrdinalOfOrdinalsSuprema ua
 open suprema pt sr

 open import UF.ImageAndSurjection pt

 surjective-simulation-gives-equality : (α β : Ordinal 𝓤)
                                      → (f : ⟨ α ⟩ → ⟨ β ⟩)
                                      → is-simulation α β f
                                      → is-surjection f
                                      → α ＝ β
 surjective-simulation-gives-equality α β f sim surj = ⊴-antisym α β (f , sim) (h₀ , h₀-sim)
   where
     prp : (b : ⟨ β ⟩) → is-prop (Σ a ꞉ ⟨ α ⟩ , (f a ＝ b))
     prp b (a , p) (a' , p') = to-subtype-＝ (λ a → underlying-type-is-set fe β)
                                            (simulations-are-lc α β f sim (p ∙ p' ⁻¹))

     h : (b : ⟨ β ⟩) → Σ a ꞉ ⟨ α ⟩ , (f a ＝ b)
     h b = ∥∥-rec (prp b) id (surj b)

     h₀ : ⟨ β ⟩ → ⟨ α ⟩
     h₀ b = pr₁ (h b)

     h₀-retract-of-f : (b : ⟨ β ⟩) → f (h₀ b) ＝ b
     h₀-retract-of-f b = pr₂ (h b)

     h₀-is-initial-segment : is-initial-segment β α h₀
     h₀-is-initial-segment b a p = f a , p'' , q
       where
        p' : f a ≺⟨ β ⟩ (f (h₀ b))
        p' = simulations-are-order-preserving α β f sim a (h₀ b) p

        p'' : f a ≺⟨ β ⟩ b
        p'' = transport (λ - → f a ≺⟨ β ⟩ -) (h₀-retract-of-f b) p'

        q : h₀ (f a) ＝ a
        q = simulations-are-lc α β f sim (h₀-retract-of-f (f a))

     h₀-is-order-preserving : is-order-preserving β α h₀
     h₀-is-order-preserving b b' p = p''
       where
         p' : f (h₀ b) ≺⟨ β ⟩ f (h₀ b')
         p' = transport₂⁻¹ (underlying-order β) (h₀-retract-of-f b) (h₀-retract-of-f b') p

         p'' : h₀ b  ≺⟨ α ⟩ (h₀ b')
         p'' = simulations-are-order-reflecting α β f sim (h₀ b) (h₀ b') p'

     h₀-sim : is-simulation β α h₀
     h₀-sim = h₀-is-initial-segment , h₀-is-order-preserving

 module _ {I : 𝓤 ̇  }
          (i₀ : I)
          (β : I → Ordinal 𝓤)
          (α : Ordinal 𝓤)
  where

  {-
  f : ⟨ [𝟙+ α ]^ (sup β) ⟩ → ⟨ sup (λ i → [𝟙+ α ]^ (β i)) ⟩
  f ([] , δ) = sum-to-sup (λ i → [𝟙+ α ]^ β i) (i₀ , ([] , []-decr))
  f ((a , x ∷ l) , δ) = {!!}
  -}

  private
   γ : I → Ordinal 𝓤
   γ i = [𝟙+ α ]^ (β i)

   ι : (ζ : I → Ordinal 𝓤) → {i : I} → ⟨ ζ i ⟩ → ⟨ sup ζ ⟩
   ι ζ {i} = pr₁ (sup-is-upper-bound ζ i)

   ι-is-simulation : (ζ : I → Ordinal 𝓤) → {i : I}
                   → is-simulation (ζ i) (sup ζ ) (ι ζ)
   ι-is-simulation ζ {i} = pr₂ (sup-is-upper-bound ζ i)

   ι-is-order-preserving : (ζ : I → Ordinal 𝓤) {i : I}
                         → is-order-preserving (ζ i) (sup ζ) (ι ζ)
   ι-is-order-preserving ζ {i} = simulations-are-order-preserving (ζ i) (sup ζ) (ι ζ) (ι-is-simulation ζ)

   ι-is-order-reflecting : (ζ : I → Ordinal 𝓤) {i : I}
                         → is-order-reflecting (ζ i) (sup ζ) (ι ζ)
   ι-is-order-reflecting ζ {i} = simulations-are-order-reflecting (ζ i) (sup ζ) (ι ζ) (ι-is-simulation ζ)

   ι-is-lc : (ζ : I → Ordinal 𝓤) {i : I}
           → left-cancellable (ι ζ)
   ι-is-lc ζ {i} = simulations-are-lc (ζ i) (sup ζ) (ι ζ) (ι-is-simulation ζ)

   ι-is-initial-segment : (ζ : I → Ordinal 𝓤) → {i : I}
                        → is-initial-segment (ζ i) (sup ζ ) (ι ζ)
   ι-is-initial-segment ζ {i} = simulations-are-initial-segments (ζ i) (sup ζ) (ι ζ) (ι-is-simulation ζ)

   ι-is-surjective : (ζ : I → Ordinal 𝓤) (s : ⟨ sup ζ ⟩)
                   → ∃ i ꞉ I , Σ x ꞉ ⟨ ζ i ⟩ , ι ζ {i} x ＝ s
   ι-is-surjective = sup-is-upper-bound-jointly-surjective

   ι-is-surjective⁺ : (ζ : I → Ordinal 𝓤) (s : ⟨ sup ζ ⟩) (i : I) (x : ⟨ ζ i ⟩)
                    → s ≺⟨ sup ζ ⟩ ι ζ x
                    → Σ y ꞉ ⟨ ζ i ⟩ , ι ζ {i} y ＝ s
   ι-is-surjective⁺ ζ s i x p =
    h (simulations-are-initial-segments (ζ i) (sup ζ) (ι ζ) (ι-is-simulation ζ) x s p)
    where
     h : Σ y ꞉ ⟨ ζ i ⟩ , y ≺⟨ ζ i ⟩ x × (ι ζ y ＝ s)
       → Σ y ꞉ ⟨ ζ i ⟩ , ι ζ {i} y ＝ s
     h (y , (_ , q)) = y , q

   module _ (i : I) where
    f₁ : List (⟨ α ×ₒ β i ⟩) → List (⟨ α ×ₒ sup β ⟩)
    f₁ [] = []
    f₁ (a , b ∷ l) = a , ι β b ∷ f₁ l
    f₂ : (l : List (⟨ α ×ₒ β i ⟩))
       → is-decreasing-pr₂ α (β i) l
       → is-decreasing-pr₂ α (sup β) (f₁ l)
    f₂ [] δ = []-decr
    f₂ (a , b ∷ []) δ = sing-decr
    f₂ (a , b ∷ a' , b' ∷ l) (many-decr p δ) =
      many-decr (simulations-are-order-preserving (β i) (sup β)
                  (ι β)
                  (pr₂ (sup-is-upper-bound β i)) b' b p)
                (f₂ (a' , b' ∷ l) δ)
    f : ⟨ γ i ⟩ → ⟨ [𝟙+ α ]^ (sup β) ⟩
    f (l , δ) = f₁ l , f₂ l δ

   f₁-surj-lemma : (a : ⟨ α ⟩) (i : I) (b : ⟨ β i ⟩) (l : List (⟨ α ×ₒ sup β ⟩))
                 → is-decreasing-pr₂ α (sup β) (a , ι β b ∷ l)
                 → Σ l' ꞉ List (⟨ α ×ₒ β i ⟩) , is-decreasing-pr₂ α (β i) (a , b ∷ l')
                                              × ((a , ι β b ∷ l) ＝ f₁ i (a , b ∷ l'))
   f₁-surj-lemma a i b [] δ = [] , sing-decr , refl
   f₁-surj-lemma a i b ((a' , s) ∷ l) δ =
    (a' , b' ∷ l') ,
    many-decr order-lem₃ δ' ,
    ap (a , ι β b ∷_) (ap (λ - → a' , - ∷ l) ((pr₂ lem) ⁻¹) ∙ pr₂ (pr₂ IH))
     where
      lem : Σ b' ꞉ ⟨ β i ⟩ , ι β b' ＝ s
      lem = ι-is-surjective⁺ β s i b (is-decreasing-heads (underlying-order (sup β)) δ)
      b' : ⟨ β i ⟩
      b' = pr₁ lem
      order-lem₁ : s ≺⟨ sup β ⟩ ι β b
      order-lem₁ = is-decreasing-heads (underlying-order (sup β)) δ
      order-lem₂ : ι β b' ≺⟨ sup β ⟩ ι β b
      order-lem₂ = transport⁻¹ (λ - → underlying-order (sup β) - (ι β b)) (pr₂ lem) order-lem₁
      order-lem₃ : b' ≺⟨ β i ⟩ b
      order-lem₃ = ι-is-order-reflecting β b' b order-lem₂
      IH : Σ l' ꞉ List (⟨ α ×ₒ β i ⟩) , is-decreasing-pr₂ α (β i) (a' , b' ∷ l')
                                      × ((a' , ι β b' ∷ l) ＝ f₁ i (a' , b' ∷ l'))
      IH = f₁-surj-lemma a' i b' l
            (transport⁻¹ (λ - → is-decreasing-pr₂ α (sup β) (a' , - ∷ l)) (pr₂ lem)
              (is-decreasing-tail (underlying-order (sup β)) δ))
      l' : List (⟨ α ×ₒ β i ⟩)
      l' = pr₁ IH
      δ' : is-decreasing-pr₂ α (β i) (a' , b' ∷ l')
      δ' = pr₁ (pr₂ IH)

   f₁-surj : (l : List (⟨ α ×ₒ sup β ⟩))
           → is-decreasing-pr₂ α (sup β) l
           → ∃ i ꞉ I , Σ l' ꞉ List (⟨ α ×ₒ β i ⟩) , is-decreasing-pr₂ α (β i) l'
                                                  × (l ＝ f₁ i l')
   f₁-surj [] δ = ∣ i₀ , [] , []-decr , refl ∣
   f₁-surj (a , s ∷ l) δ = ∥∥-functor h (ι-is-surjective β s)
    where
     h : (Σ i ꞉ I , Σ b ꞉ ⟨ β i ⟩ , ι β b ＝ s)
       → Σ i ꞉ I , Σ l' ꞉ List (⟨ α ×ₒ β i ⟩) , is-decreasing-pr₂ α (β i) l'
                                              × ((a , s ∷ l) ＝ f₁ i l')
     h (i , b , refl) = i , (a , b ∷ pr₁ lem) , (pr₁ (pr₂ lem) , pr₂ (pr₂ lem))
      where
       lem : Σ l' ꞉ List ⟨ α ×ₒ β i ⟩ , is-decreasing-pr₂ α (β i) (a , b ∷ l')
                                      × (a , ι β b ∷ l ＝ f₁ i (a , b ∷ l'))
       lem = f₁-surj-lemma a i b l δ

   f-surj : (y : ⟨ [𝟙+ α ]^ (sup β) ⟩) → ∃ i ꞉ I , Σ x ꞉ ⟨ γ i ⟩ , f i x ＝ y
   f-surj (l , δ) = ∥∥-functor h (f₁-surj l δ)
    where
     h : (Σ i ꞉ I , Σ l' ꞉ List (⟨ α ×ₒ β i ⟩) , is-decreasing-pr₂ α (β i) l'
                                               × (l ＝ f₁ i l'))
       → Σ i ꞉ I , Σ x ꞉ ⟨ γ i ⟩ , (f i x ＝ l , δ)
     h (i , l' , δ , refl) = i , (l' , δ) , to-exponential-＝ α (sup β) refl

   f-is-order-preserving : (i : I) → is-order-preserving (γ i) ([𝟙+ α ]^ (sup β)) (f i)
   f-is-order-preserving i ([] , δ) (_ , ε) []-lex = []-lex
   f-is-order-preserving i ((a , b ∷ l) , δ) ((a' , b' ∷ l') , ε) (head-lex (inl m)) = head-lex (inl (ι-is-order-preserving β b b' m))
   f-is-order-preserving i ((a , b ∷ l) , δ) ((a' , b' ∷ l') , ε) (head-lex (inr (refl , m))) = head-lex (inr (refl , m))
   f-is-order-preserving i ((_ ∷ l) , δ) ((_ ∷ l') , ε) (tail-lex refl m) =
     tail-lex refl (f-is-order-preserving i (l , is-decreasing-tail (underlying-order (β i)) δ) (l' , is-decreasing-tail (underlying-order (β i)) ε) m)

   f-is-order-reflecting : (i : I) → is-order-reflecting (γ i) ([𝟙+ α ]^ (sup β)) (f i)
   f-is-order-reflecting i ([] , δ) ((a , b ∷ l) , ε) []-lex = []-lex
   f-is-order-reflecting i ((a , b ∷ l) , δ) ((a' , b' ∷ l') , ε) (head-lex (inl m)) = head-lex (inl (ι-is-order-reflecting β b b' m))
   f-is-order-reflecting i ((a , b ∷ l) , δ) ((a' , b' ∷ l') , ε) (head-lex (inr (e , m))) = head-lex (inr (ι-is-lc β e , m))
   f-is-order-reflecting i ((a , b ∷ l) , δ) ((a' , b' ∷ l') , ε) (tail-lex e m) =
    tail-lex (to-×-＝ (ap pr₁ e) (ι-is-lc β (ap pr₂ e)))
    (f-is-order-reflecting i (l , is-decreasing-tail (underlying-order (β i)) δ) (l' , is-decreasing-tail (underlying-order (β i)) ε) m)

   -- We factor out:
   partial-invertibility-lemma : (i : I) -- (a : ⟨ α ⟩) (b : ⟨ β i ⟩)
                               → (l : List (⟨ α ×ₒ β i ⟩))
                               → is-decreasing-pr₂ α (sup β) (f₁ i l) -- (f₁ i (a , b ∷ l))
                               → is-decreasing-pr₂ α (β i) l -- (a , b ∷ l)
   partial-invertibility-lemma i [] ds = []-decr
   partial-invertibility-lemma i ((a , b) ∷ []) ds = sing-decr
   partial-invertibility-lemma i ((a , b) ∷ (a' , b') ∷ l) (many-decr m ds) =
     many-decr (ι-is-order-reflecting β b' b m) (partial-invertibility-lemma i ((a' , b') ∷ l) ds)

   f-is-partially-invertible : (i : I)
                             → (xs : List ⟨ α ×ₒ β i ⟩) → (δ : is-decreasing-pr₂ α (β i) xs)
                             → (ys : List ⟨ α ×ₒ sup β ⟩) → (ε : is-decreasing-pr₂ α (sup β) ys)
                             → (ys , ε) ≺⟨ [𝟙+ α ]^ (sup β) ⟩ f i (xs , δ)
                             → Σ xs' ꞉ ⟨ γ i ⟩ , f i xs' ＝ (ys , ε)
   f-is-partially-invertible i xs δ [] []-decr p = ([] , []-decr) , refl
   f-is-partially-invertible i ((a , b) ∷ xs) δ ((a' , b') ∷ []) ε (head-lex (inl m)) = ((a' , pr₁ ι-sim ∷ []) , sing-decr) , (to-exponential-＝ α (sup β) (ap (λ - → (a' , -) ∷ []) (pr₂ (pr₂ ι-sim))))
     where
       ι-sim = ι-is-initial-segment β b b' m
   f-is-partially-invertible i ((a , b) ∷ xs) δ ((a' , b') ∷ (a₁ , b₁) ∷ ys) (many-decr p ε) (head-lex (inl m)) =
     let IH = f-is-partially-invertible i ((a , b) ∷ xs) δ ((a₁ , b₁) ∷ ys) ε (head-lex (inl (Transitivity (sup β) _ _ _ p m)))
         xs' = pr₁ (pr₁ IH)
         ι-sim = ι-is-initial-segment β b b' m
         b₀ = pr₁ ι-sim
         p₀ = transport⁻¹ (λ - → b₁ ≺⟨ sup β ⟩ -) (pr₂ (pr₂ ι-sim)) p
     in ((a' , b₀ ∷ xs') , partial-invertibility-lemma i ((a' , b₀) ∷ xs') (transport⁻¹ (λ - → is-decreasing-pr₂ α (sup β) ((a' , ι β b₀) ∷ -)) (ap pr₁ (pr₂ IH)) (many-decr p₀ ε)))
       , (to-exponential-＝ α (sup β) (ap₂ (λ x y → (a' , x) ∷ y) (pr₂ (pr₂ ι-sim)) (ap pr₁ (pr₂ IH))))
   f-is-partially-invertible i ((a , b) ∷ xs) δ ((a' , .(ι β b)) ∷ []) ε (head-lex (inr (refl , m))) = ((a' , b ∷ []) , sing-decr) , (to-exponential-＝ α (sup β) refl)
   f-is-partially-invertible i ((a , b) ∷ xs) δ ((a' , .(ι β b)) ∷ (a₁ , b₁) ∷ ys) (many-decr p ε) (head-lex (inr (refl , m))) =
     let IH = f-is-partially-invertible i ((a , b) ∷ xs) δ ((a₁ , b₁) ∷ ys) ε (head-lex (inl p))
         xs' = pr₁ (pr₁ IH)
     in (((a' , b) ∷ xs') , partial-invertibility-lemma i ((a' , b) ∷ xs')
                                                          (transport⁻¹ (λ - → is-decreasing-pr₂ α (sup β) ((a' , ι β b) ∷ -)) (ap pr₁ (pr₂ IH)) (many-decr p ε)))
        , to-exponential-＝ α (sup β) (ap ((a' , ι β b) ∷_) (ap pr₁ (pr₂ IH)))
   f-is-partially-invertible i ((a , b) ∷ xs) δ (.(a , ι β b) ∷ ys) ε (tail-lex refl p) =
     let IH = f-is-partially-invertible i xs (is-decreasing-tail (underlying-order (β i)) δ) ys (is-decreasing-tail (underlying-order (sup β)) ε) p
     in (((a , b) ∷ pr₁ (pr₁ IH)) , partial-invertibility-lemma i ((a , b) ∷ pr₁ (pr₁ IH))
                                                                  (transport⁻¹ (λ - → is-decreasing-pr₂ α (sup β) ((a , ι β b) ∷ -)) (ap pr₁ (pr₂ IH)) ε))
       , to-exponential-＝ α (sup β) (ap ((a , ι β b) ∷_) (ap pr₁ (pr₂ IH)))

   f-is-initial-segment : (i : I) → is-initial-segment (γ i) ([𝟙+ α ]^ (sup β)) (f i)
   f-is-initial-segment i = order-reflecting-and-partial-inverse-is-initial-segment (γ i) ([𝟙+ α ]^ (sup β)) (f i) (f-is-order-reflecting i) g
     where
       g : (xs : ⟨ γ i ⟩) → (ys : ⟨ [𝟙+ α ]^ (sup β) ⟩) → ys ≺⟨ [𝟙+ α ]^ (sup β) ⟩ f i xs → Σ xs' ꞉ ⟨ γ i ⟩ , f i xs' ＝ ys
       g (xs , δ) (ys , ε) = f-is-partially-invertible i xs δ ys ε

  exp-sup-is-upper-bound : (i : I) → γ i ⊴ ([𝟙+ α ]^ (sup β))
  exp-sup-is-upper-bound i = f i , f-is-initial-segment i , f-is-order-preserving i

  exp-sup-simulation : sup (λ i → ([𝟙+ α ]^ (β i))) ⊴ ([𝟙+ α ]^ (sup β))
  exp-sup-simulation = sup-is-lower-bound-of-upper-bounds (λ i → ([𝟙+ α ]^ (β i))) ([𝟙+ α ]^ (sup β)) exp-sup-is-upper-bound

  exp-sup-simulation-surjective : is-surjection (pr₁ exp-sup-simulation)
  exp-sup-simulation-surjective = surjectivity-lemma γ ([𝟙+ α ]^ (sup β)) exp-sup-is-upper-bound f-surj

  sup-spec : sup (λ i → ([𝟙+ α ]^ (β i))) ＝ ([𝟙+ α ]^ (sup β))
  sup-spec = surjective-simulation-gives-equality
               (sup (λ i → ([𝟙+ α ]^ (β i))))
               ([𝟙+ α ]^ (sup β))
               (pr₁ exp-sup-simulation)
               (pr₂ exp-sup-simulation)
               exp-sup-simulation-surjective

 exp-sup-spec : (α : Ordinal 𝓤) {I : 𝓤 ̇  } → ∥ I ∥ → (β : I → Ordinal 𝓤) → sup (λ i → ([𝟙+ α ]^ (β i))) ＝ ([𝟙+ α ]^ (sup β))
 exp-sup-spec α i β = ∥∥-rec (the-type-of-ordinals-is-a-set (ua _) fe') (λ i₀ → sup-spec i₀ β α) i

\end{code}
