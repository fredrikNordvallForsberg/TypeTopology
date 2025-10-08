Martin Escardo, Paulo Oliva, 27th November 2024 - 14th May 2025

We define optimal moves and optimal plays for sequential games. Then
using the JT monad, with T the monad List⁺ of non-empty lists, we
compute all optimal plays of a game, provided it has ordinary
selection functions.

\begin{code}

{-# OPTIONS --safe --without-K #-}

open import MLTT.Spartan hiding (J)
open import UF.FunExt
open import UF.DiscreteAndSeparated

\end{code}

We work with a type of outcomes R with decidable equality (called
discreteness).

\begin{code}

module Games.OptimalPlays
        (fe : Fun-Ext)
        (R  : Type)
        (R-is-discrete : is-discrete R)
       where

open import Games.FiniteHistoryDependent R
open import Games.TypeTrees
open import MLTT.List hiding ([_]) renaming (map to lmap)
open import MonadOnTypes.J-transf-variation
open import MonadOnTypes.JK
open import MonadOnTypes.K
open import MonadOnTypes.List
open import MonadOnTypes.Monad
open import MonadOnTypes.NonEmptyList
open import Notation.CanonicalMap
open import UF.Base
open import UF.Subsingletons

open K-definitions R

\end{code}

The following are the main two notions considered in this file.

\begin{code}

is-optimal-move : {X : Type}
                  {Xf : X → 𝑻}
                  (q : (Σ x ꞉ X , Path (Xf x)) → R)
                  (ϕ : K X)
                  (ϕf : (x : X) → 𝓚 (Xf x))
                → X
                → Type
is-optimal-move {X} {Xf} q ϕ ϕf x =
 optimal-outcome (game (X ∷ Xf) q (ϕ :: ϕf))
 ＝ optimal-outcome (game (Xf x) (subpred q x) (ϕf x))

is-optimal-play : {Xt : 𝑻} → 𝓚 Xt → (Path Xt → R) → Path Xt → Type
is-optimal-play {[]}     ⟨⟩        q ⟨⟩        = 𝟙
is-optimal-play {X ∷ Xf} (ϕ :: ϕf) q (x :: xs) =
   is-optimal-move {X} {Xf} q ϕ ϕf x
 × is-optimal-play {Xf x} (ϕf x) (subpred q x) xs

\end{code}

Being an optimal move is a decidable proposition.

\begin{code}

being-optimal-move-is-prop : {X : Type}
                             {Xf : X → 𝑻}
                             (q : (Σ x ꞉ X , Path (Xf x)) → R)
                             (ϕ : K X)
                             (ϕf : (x : X) → 𝓚 (Xf x))
                             (x : X)
                           → is-prop (is-optimal-move q ϕ ϕf x)
being-optimal-move-is-prop q ϕ ϕf x = discrete-types-are-sets R-is-discrete

being-optimal-move-is-decidable : {X : Type}
                                  {Xf : X → 𝑻}
                                  (q : (Σ x ꞉ X , Path (Xf x)) → R)
                                  (ϕ : K X)
                                  (ϕf : (x : X) → 𝓚 (Xf x))
                                  (x : X)
                                → is-decidable (is-optimal-move q ϕ ϕf x)
being-optimal-move-is-decidable q ϕ ϕf x = R-is-discrete _ _

\end{code}



We now show that the strategic path of a strategy in subgame perfect
equilibrium is an optimal play. We start with a lemma that is
interesting on its own right.

\begin{code}

optimal-play-gives-optimal-outcome
 : {Xt : 𝑻}
   (ϕt : 𝓚 Xt)
   (q : Path Xt → R)
   (xs : Path Xt)
 → is-optimal-play {Xt} ϕt q xs
 → q xs ＝ optimal-outcome (game Xt q ϕt)
optimal-play-gives-optimal-outcome {[]}     ⟨⟩        q ⟨⟩        ⟨⟩ = refl
optimal-play-gives-optimal-outcome {X ∷ Xf} (ϕ :: ϕf) q (x :: xs) (o :: os)
 = subpred q x xs                                     ＝⟨ IH ⟩
   optimal-outcome (game (Xf x) (subpred q x) (ϕf x)) ＝⟨ o ⁻¹ ⟩
   optimal-outcome (game (X ∷ Xf) q (ϕ :: ϕf))        ∎
 where
  IH : subpred q x xs ＝ optimal-outcome (game (Xf x) (subpred q x) (ϕf x))
  IH = optimal-play-gives-optimal-outcome {Xf x} (ϕf x) (subpred q x) xs os

strategic-path-is-optimal-play
 : {Xt : 𝑻}
   (ϕt : 𝓚 Xt)
   (q : Path Xt → R)
   (σ : Strategy Xt)
 → is-in-sgpe ϕt q σ
 → is-optimal-play ϕt q (strategic-path σ)
strategic-path-is-optimal-play {[]} ⟨⟩ q ⟨⟩ ⟨⟩ = ⋆
strategic-path-is-optimal-play {X ∷ Xf} ϕt@(ϕ :: ϕf) q σ@(x₀ :: σf) ot@(o :: os)
 = I , IH x₀
 where
  IH : (x : X) → is-optimal-play (ϕf x) (subpred q x) (strategic-path (σf x))
  IH x = strategic-path-is-optimal-play {Xf x} (ϕf x) (subpred q x) (σf x) (os x)

  I : is-optimal-move q ϕ ϕf x₀
  I = optimal-outcome (game (X ∷ Xf) q (ϕ :: ϕf))                  ＝⟨ refl ⟩
      sequenceᴷ {X ∷ Xf} (ϕ :: ϕf) q                               ＝⟨ refl ⟩
      ϕ (λ x → sequenceᴷ (ϕf x) (subpred q x))                     ＝⟨ refl ⟩
      ϕ (λ x → optimal-outcome (game (Xf x) (subpred q x) (ϕf x))) ＝⟨ I₁ ⟩
      ϕ (λ x → subpred q x (strategic-path (σf x)))                ＝⟨ o ⁻¹ ⟩
      q (strategic-path σ)                                         ＝⟨ refl ⟩
      subpred q x₀ (strategic-path (σf x₀))                        ＝⟨ I₂ ⟩
      optimal-outcome (game (Xf x₀) (subpred q x₀) (ϕf x₀))        ∎
       where
        I₀ : (x : X)
           → optimal-outcome (game (Xf x) (subpred q x) (ϕf x))
           ＝ subpred q x (strategic-path (σf x))
        I₀ x = (optimal-play-gives-optimal-outcome
                 (ϕf x) (subpred q x) (strategic-path (σf x)) (IH x))⁻¹

        I₁ = ap ϕ (dfunext fe I₀)
        I₂ = optimal-play-gives-optimal-outcome
              (ϕf x₀) (subpred q x₀) (strategic-path (σf x₀)) (IH x₀)

\end{code}

We now proceed to compute the non-empty list of all optimal plays of a
game, under suitable assumptions on the game.

The algebras of the nonempty list monad 𝕃⁺ are the semigroups
(associative magmas). We work with the magma structure on R defined by
x · y = x. Concretely, this amounts to the following construction.

\begin{code}

𝓐 : Algebra 𝕃⁺ R
𝓐 = record {
     structure-map = head⁺ ;
     aunit = u ;
     aassoc = a
    }
 where
  u : head⁺ ∘ η 𝕃⁺ ∼ id
  u r = refl

  a : head⁺ ∘ ext 𝕃⁺ (η 𝕃⁺ ∘ head⁺) ∼ head⁺ ∘ ext 𝕃⁺ id
  a ((((r ∷ _) , _) ∷ _) , _) = refl

open T-definitions 𝕃⁺
open α-definitions 𝕃⁺ R 𝓐
open JT-definitions 𝕃⁺ R 𝓐 fe
open JK R

\end{code}

Ordinary selection functions are of type J X := (X → R) → X. Here we
work with JT defined as follows.

\begin{code}

JT-remark : JT ＝ λ X → (X → R) → List⁺ X
JT-remark = by-definition

\end{code}

Every algebra α of any monad T induces an extension operator α­extᵀ,
which for the case T = List⁺ with the algebra defined above is
characterized as follows.

\begin{code}

α-extᵀ-explicitly : {X : Type} (p : X → R) (t : List⁺ X)
                  → α-extᵀ p t ＝ p (head⁺ t)
α-extᵀ-explicitly p ((x ∷ _) :: _) = refl

\end{code}

We now construct a JT-selection function ε⁺ from an ordinary
J-selection function ε that attains a quantifier ϕ, for any listed
type X with at least one element.

Recall that we say that a type is listed⁺ if it has a distinguished
element and a list of all its elements (which will automatically
include the distinguished element).

\begin{code}

module _ (X : Type)
         (X-is-listed⁺@(x₀ , xs , μ) : listed⁺ X)
         (ϕ : (X → R) → R)
      where

 private
  A : (X → R) → X → Type
  A p x = p x ＝ ϕ p

  δA : (p : X → R) (x : X) → is-decidable (A p x)
  δA p x = R-is-discrete (p x) (ϕ p)

 εᴸ :  (X → R) → List X
 εᴸ p = filter (A p) (δA p) xs

 εᴸ-property→ : (p : X → R) (x : X) → member x (εᴸ p) → p x ＝ ϕ p
 εᴸ-property→ p x = filter-member→ (A p) (δA p) x xs

 εᴸ-property← : (p : X → R) (x : X) → p x ＝ ϕ p → member x (εᴸ p)
 εᴸ-property← p x e = filter-member← (A p) (δA p) x xs e (μ x)

 module _ (ε : (X → R) → X)
          (ε-attains-ϕ : ε attains ϕ)
        where

  ε-member-of-εᴸ : (p : X → R) → member (ε p) (εᴸ p)
  ε-member-of-εᴸ p = filter-member← (A p) (δA p) (ε p) xs (ε-attains-ϕ p) (μ (ε p))

  εᴸ-is-non-empty : (p : X → R) → is-non-empty (εᴸ p)
  εᴸ-is-non-empty p = lists-with-members-are-non-empty (ε-member-of-εᴸ p)

  ε⁺ : JT X
  ε⁺ p = εᴸ p , εᴸ-is-non-empty p

\end{code}

We now extend this to trees of selection functions that attain
quantifiers.

\begin{code}

𝓙𝓣 : 𝑻 → Type
𝓙𝓣 = structure JT

εt⁺ : (Xt : 𝑻)
    → structure listed⁺ Xt
    → (ϕt : 𝓚 Xt)
    → (εt : 𝓙 Xt)
    → εt Attains ϕt
    → 𝓙𝓣 Xt
εt⁺ [] ⟨⟩ ⟨⟩ ⟨⟩ ⟨⟩ = ⟨⟩
εt⁺ (X ∷ Xf) (l :: lf) (ϕ :: ϕf) (ε :: εf) (a :: af) =
 ε⁺ X l ϕ ε a :: (λ x → εt⁺ (Xf x) (lf x) (ϕf x) (εf x) (af x))

open List⁺-definitions

\end{code}

We now prove a couple of technical lemmas.

\begin{code}

module _ {X : Type} {Xf : X → 𝑻}
         (e⁺ : JT X)
         (d⁺ : (x : X) → JT (Path (Xf x)))
         (q : Path (X ∷ Xf)  → R)
       where

 private
  g : (x : X) → T (Path (Xf x))
  g x = d⁺ x (subpred q x)

  f : X → R
  f x = α-extᵀ (subpred q x) (g x)

  xt : T X
  xt = e⁺ f

  x : X
  x = head⁺ xt

  xs : Path (Xf x)
  xs = head⁺ (g x)

 head⁺-of-⊗ᴶᵀ : head⁺ ((e⁺ ⊗ᴶᵀ d⁺) q) ＝ x :: xs
 head⁺-of-⊗ᴶᵀ =
  head⁺ ((e⁺ ⊗ᴶᵀ d⁺) q)                                         ＝⟨ I ⟩
  head⁺ (xt ⊗ᴸ⁺ g)                                              ＝⟨ II ⟩
  head⁺ (concat⁺ (lmap⁺ (λ x → lmap⁺ (λ y → x :: y) (g x)) xt)) ＝⟨ III ⟩
  head⁺ (head⁺ (lmap⁺ (λ x → lmap⁺ (λ y → x :: y) (g x)) xt))   ＝⟨ IV ⟩
  head⁺ (lmap⁺ (head⁺ xt ::_) (g (head⁺ xt)))                   ＝⟨ refl ⟩
  head⁺ (lmap⁺ (x ::_) (g x))                                   ＝⟨ V ⟩
  x :: head⁺ (g x)                                              ＝⟨ refl ⟩
  x :: xs                                                       ∎
   where
    I   = ap head⁺ (⊗ᴶᵀ-in-terms-of-⊗ᵀ e⁺ d⁺ q fe)
    II  = ap head⁺ (⊗ᴸ⁺-explicitly fe (e⁺ f) g)
    III = head⁺-of-concat⁺ (lmap⁺ (λ x → lmap⁺ (λ y → x :: y) (g x)) xt)
    IV  = ap head⁺ (head⁺-of-lmap⁺ (λ x → lmap⁺ (λ y → x :: y) (g x)) xt)
    V   = head⁺-of-lmap⁺ (x ::_) (g x)

JT-in-terms-of-K : (Xt : 𝑻)
                   (ϕt : 𝓚 Xt)
                   (q : Path Xt → R)
                   (εt : 𝓙 Xt)
                   (at : εt Attains ϕt)
                   (lt : structure listed⁺ Xt)
                 → α-extᵀ q (path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q)
                 ＝ path-sequence (𝕂 R) ϕt q
JT-in-terms-of-K [] ϕt q εt at lt = refl
JT-in-terms-of-K Xt@(X ∷ Xf) ϕt@(ϕ :: ϕf) q εt@(ε :: εf) at@(a :: af) lt@(l :: lf) = II
 where
  d⁺ : (x : X) → JT (Path (Xf x))
  d⁺ x = path-sequence 𝕁𝕋 (εt⁺ (Xf x) (lf x) (ϕf x) (εf x) (af x))

  f : (x : X) → List⁺ (Path (Xf x))
  f x = d⁺ x (subpred q x)

  p : X → R
  p x = α-extᵀ (subpred q x) (f x)

  IH : (x : X) → p x ＝ path-sequence (𝕂 R) (ϕf x) (subpred q x)
  IH x = JT-in-terms-of-K (Xf x) (ϕf x) (subpred q x) (εf x) (af x) (lf x)

  e⁺ : JT X
  e⁺ = ε⁺ X l ϕ ε a

  x : X
  x = head⁺ (e⁺ p)

  I : member x (ι (e⁺ p))
  I = head⁺-is-member (e⁺ p)

  II = α-extᵀ q ((e⁺ ⊗ᴶᵀ d⁺) q)                           ＝⟨ II₀ ⟩
       q (head⁺ ((e⁺ ⊗ᴶᵀ d⁺) q))                          ＝⟨ II₁ ⟩
       q (x :: head⁺ (f x))                               ＝⟨ II₂ ⟩
       p x                                                ＝⟨ II₃ ⟩
       ϕ p                                                ＝⟨ II₄ ⟩
       ϕ (λ x → path-sequence (𝕂 R) (ϕf x) (subpred q x)) ＝⟨ refl ⟩
       (ϕ ⊗[ 𝕂 R ] (λ x → path-sequence (𝕂 R) (ϕf x))) q  ∎
        where
         II₀ = α-extᵀ-explicitly q ((e⁺ ⊗[ 𝕁𝕋 ] d⁺) q)
         II₁ = ap q (head⁺-of-⊗ᴶᵀ e⁺ d⁺ q)
         II₂ = (α-extᵀ-explicitly (subpred q x) (f x))⁻¹
         II₃ = εᴸ-property→ X l ϕ p x I
         II₄ = ap ϕ (dfunext fe IH)

\end{code}

We now show that path-sequence 𝕁𝕋 computes the non-empty list of all
optimal plays.

\begin{code}

main-lemma→ : (Xt : 𝑻)
              (ϕt : 𝓚 Xt)
              (q : Path Xt → R)
              (εt : 𝓙 Xt)
              (at : εt Attains ϕt)
              (lt : structure listed⁺ Xt)
              (xs : Path Xt)
            → member xs (ι (path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q))
            → is-optimal-play ϕt q xs
main-lemma→ [] ⟨⟩ q ⟨⟩ ⟨⟩ ⟨⟩ ⟨⟩ in-head = ⟨⟩
main-lemma→ Xt@(X ∷ Xf) ϕt@(ϕ :: ϕf) q εt@(ε :: εf) at@(a :: af)
            lt@(l :: lf) (x :: xs) m =
 head-is-optimal-move , tail-is-optimal-play
 where
  e⁺ : JT X
  e⁺ = ε⁺ X l ϕ ε a

  d⁺ : (x : X) → JT (Path (Xf x))
  d⁺ x = path-sequence 𝕁𝕋 (εt⁺ (Xf x) (lf x) (ϕf x) (εf x) (af x))

  t : List⁺ X
  t = τ e⁺ d⁺ q

  tf : (x : X) → T (Path (Xf x))
  tf x = d⁺ x (subpred q x)

  p : X → R
  p x = path-sequence (𝕂 R) (ϕf x) (subpred q x)

  p' : X → R
  p' x = α-extᵀ
          (subpred q x)
          (path-sequence 𝕁𝕋
            (εt⁺ (Xf x) (lf x) (ϕf x) (εf x) (af x))
            (subpred q x))

  I : path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q ＝ t ⊗ᴸ⁺ tf
  I = ⊗ᴶᵀ-in-terms-of-⊗ᵀ e⁺ d⁺ q fe

  II : member (x :: xs) (ι (t ⊗ᴸ⁺ tf))
  II = transport (member (x :: xs)) (ap ι I) m

  III : member x (ι t)
  III = pr₁ (split-membership fe x xs t tf II)

  IV : member xs (ι (tf x))
  IV = pr₂ (split-membership fe x xs t tf II)

  V : p' ∼ p
  V x = JT-in-terms-of-K (Xf x) (ϕf x) (subpred q x) (εf x ) (af x) (lf x)

  VI : t ＝ e⁺ p
  VI = ap e⁺ (dfunext fe V)

  VII : member x (ι (e⁺ p))
  VII = transport (λ - → member x (ι -)) VI III

  head-is-optimal-move =
   ϕ p                                      ＝⟨ VIII ⟩
   p x                                      ＝⟨ refl ⟩
   path-sequence (𝕂 R) (ϕf x) (subpred q x) ∎
    where
     VIII = (εᴸ-property→ X l ϕ p x VII)⁻¹

  IH : member xs (ι (tf x))
     → is-optimal-play (ϕf x) (subpred q x) xs
  IH = main-lemma→ (Xf x) (ϕf x) (subpred q x) (εf x) (af x) (lf x) xs

  tail-is-optimal-play : is-optimal-play (ϕf x) (subpred q x) xs
  tail-is-optimal-play = IH IV

main-lemma← : (Xt : 𝑻)
              (ϕt : 𝓚 Xt)
              (q : Path Xt → R)
              (εt : 𝓙 Xt)
              (at : εt Attains ϕt)
              (lt : structure listed⁺ Xt)
              (xs : Path Xt)
            → is-optimal-play ϕt q xs
            → member xs (ι (path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q))
main-lemma← [] ⟨⟩ q ⟨⟩ ⟨⟩ ⟨⟩ ⟨⟩ ⋆ = in-head
main-lemma← Xt@(X ∷ Xf) ϕt@(ϕ :: ϕf) q εt@(ε :: εf) at@(a :: af)
            lt@(l :: lf) (x :: xs) (om , op) = VI
 where
  p : X → R
  p x = path-sequence (𝕂 R) (ϕf x) (subpred q x)

  e⁺ : JT X
  e⁺ = ε⁺ X l ϕ ε a

  d⁺ : (x : X) → JT (Path (Xf x))
  d⁺ x = path-sequence 𝕁𝕋 (εt⁺ (Xf x) (lf x) (ϕf x) (εf x) (af x))

  t : List⁺ X
  t = τ e⁺ d⁺ q

  tf : (x : X) → T (Path (Xf x))
  tf x = d⁺ x (subpred q x)

  p' : X → R
  p' x = α-extᵀ (subpred q x) (tf x)

  IH : member xs (ι (tf x))
  IH = main-lemma← (Xf x) (ϕf x) (subpred q x) (εf x) (af x) (lf x) xs op

  I : p ＝ p'
  I = dfunext fe
       (λ x → (JT-in-terms-of-K (Xf x) (ϕf x) (subpred q x) (εf x) (af x) (lf x))⁻¹)

  II : p' x ＝ ϕ p'
  II = transport (λ - → - x ＝ ϕ -) I (om ⁻¹)

  III : member x (ι t)
  III = εᴸ-property← X l ϕ p' x II

  IV : member (x :: xs) (ι (t ⊗ᴸ⁺ tf))
  IV = join-membership fe x xs t tf (III , IH)

  V : ι (t ⊗ᴸ⁺ tf) ＝ ι (path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q)
  V = (ap ι (⊗ᴶᵀ-in-terms-of-⊗ᵀ e⁺ d⁺ q fe))⁻¹

  VI : member (x :: xs) (ι (path-sequence 𝕁𝕋 (εt⁺ Xt lt ϕt εt at) q))
  VI = transport (member (x :: xs)) V IV

\end{code}

To conclude, we package the above with a game as a parameter, where
the types of moves are listed, and where we are given attaining
selection functions for the quantifiers.

\begin{code}

module _ (G@(game Xt q ϕt) : Game)
         (Xt-is-listed⁺ : structure listed⁺ Xt)
         (εt : 𝓙 Xt)
         (εt-Attains-ϕt : εt Attains ϕt)
       where

 optimal-plays : List⁺ (Path Xt)
 optimal-plays = path-sequence 𝕁𝕋 (εt⁺ Xt Xt-is-listed⁺ ϕt εt εt-Attains-ϕt) q

 Theorem→ : (xs : Path Xt) → member xs (ι optimal-plays) → is-optimal-play ϕt q xs
 Theorem→ = main-lemma→ Xt ϕt q εt εt-Attains-ϕt Xt-is-listed⁺

 Theorem← : (xs : Path Xt) → is-optimal-play ϕt q xs → member xs (ι optimal-plays)
 Theorem← = main-lemma← Xt ϕt q εt εt-Attains-ϕt Xt-is-listed⁺

\end{code}

This concludes what we wished to construct and prove.

Remark. The assumption Xt-is-listed⁺ implies that the type R of
outcomes has at least one element.

\begin{code}

 r₀ : R
 r₀ = q (head⁺ optimal-plays)

\end{code}

In a previous version of this file, we instead assumed r₀ : R, and we
worked with "listed" instead of "listed⁺", but the listings were
automatically non-empty.

Added 24th September 2025.

\begin{code}

quantifiers-over-empty-types-are-not-attainable
 : {X : Type}
 → is-empty X
 → (ϕ : K X)
 → ¬ is-attainable ϕ
quantifiers-over-empty-types-are-not-attainable e ϕ (ε , a)
 = e (ε (unique-from-𝟘 ∘ e))

\end{code}

TODO. It is not in general decidable whether a quantifier is attainable.

Added 17th September. We calculate the subtree of the game tree whose
paths are precisely the optimal plays of the original game.

\begin{code}

prune : (Xt : 𝑻)
        (q : Path Xt → R)
        (ϕt : 𝓚 Xt)
      → 𝑻
prune [] q ⟨⟩ = []
prune (X ∷ Xf) q (ϕ :: ϕf) = (Σ x ꞉ X , is-optimal-move q ϕ ϕf x)
                           ∷ (λ (x , o) → prune (Xf x) (subpred q x) (ϕf x))
\end{code}

Notice that it may happen that the pruned tree is non-empty, but all
the nodes in the tree are empty types of moves. So we can't use the
pruned tree to decide whether or not there is an optimal
play. However, if we further assume that the types of moves in the
original tree are listed, we can decide this, and, moreover, get the
list of all optimal plays from the pruned tree *without* assuming that
the quantifiers are attainable (as we did above).

Each path in the pruned tree is a path in the original tree.

\begin{code}

inclusion : {Xt : 𝑻}
            (q : Path Xt → R)
            (ϕt : 𝓚 Xt)
          → Path (prune Xt q ϕt)
          → Path Xt
inclusion {[]} q ⟨⟩ ⟨⟩ = ⟨⟩
inclusion {X ∷ Xf} q (ϕ :: ϕf) ((x , _) :: xos)
 = x :: inclusion {Xf x} (subpred q x) (ϕf x) xos

\end{code}

The predicate q restricts to a predicate in the pruned tree.

\begin{code}

restriction : {Xt : 𝑻}
              (q : Path Xt → R)
              (ϕt : 𝓚 Xt)
            → Path (prune Xt q ϕt) → R
restriction q ϕt = q ∘ inclusion q ϕt

\end{code}

The paths in the pruned tree are precisely the optimals plays in the
original tree.

\begin{code}

lemma→ : {Xt : 𝑻}
         (q : Path Xt → R)
         (ϕt : 𝓚 Xt)
       → (xos : Path (prune Xt q ϕt))
       → is-optimal-play ϕt q (inclusion q ϕt xos)
lemma→ {[]} q ⟨⟩ ⟨⟩ = ⟨⟩
lemma→ {X ∷ Xf} q (ϕ :: ϕf) ((x , o) :: xos)
 = o , lemma→ {Xf x} (subpred q x) (ϕf x) xos

lemma← : {Xt : 𝑻}
         (q : Path Xt → R)
         (ϕt : 𝓚 Xt)
         (xs : Path Xt)
       → is-optimal-play ϕt q xs
       → Σ xos ꞉ Path (prune Xt q ϕt) , inclusion q ϕt xos ＝ xs
lemma← {[]} q ⟨⟩ ⟨⟩ ⟨⟩ = ⟨⟩ , refl
lemma← {X ∷ Xf} q (ϕ :: ϕf) (x :: xs) (o :: os)
 = ((x , o) :: pr₁ IH) , ap (x ::_) (pr₂ IH)
 where
  IH : Σ xos ꞉ Path (prune (Xf x) (subpred q x) (ϕf x))
             , inclusion (subpred q x) (ϕf x) xos ＝ xs
  IH = lemma← {Xf x} (subpred q x) (ϕf x) xs os

\end{code}

This gives an alternative way to calculate the list of optimal plays,
which doesn't use selection functions.

Added 8th October 2025.

TODO. Move the following general purpose functions on paths and on
lists to appropriate modules. Also think of better names for the
functions.

\begin{code}

module _ {X : Type}
         {Xf : X → 𝑻}
       where

 prepend : (x : X)
         → List (Path (Xf x))
         → List (Path (X ∷ Xf))
 prepend x [] = []
 prepend x (xs ∷ xss) = (x :: xs) ∷ prepend x xss

 map-prepend : ((x : X) → List (Path (Xf x)))
             → List X
             → List (List (Path (X ∷ Xf)))
 map-prepend f [] = []
 map-prepend f (x ∷ xs) = prepend x (f x) ∷ map-prepend f xs

 map-concat-prepend : ((x : X) → List (Path (Xf x)))
                    → List X
                    → List (Path (X ∷ Xf))
 map-concat-prepend f [] = []
 map-concat-prepend f (x ∷ xs) = prepend x (f x) ++ map-concat-prepend f xs


list-of-paths : (Xt : 𝑻)
                (Xt-is-listed : structure listed Xt)
              → List (Path Xt)
list-of-paths [] ⟨⟩ = []
list-of-paths (X ∷ Xf) ((xs , m) , Xf-is-listed) = map-concat-prepend IH xs
 where
  IH : (x : X) → List (Path (Xf x))
  IH x = list-of-paths (Xf x) (Xf-is-listed x)

conditionally-prepend : {X : 𝓤 ̇ } (A : X → 𝓥 ̇ )
                      → (x : X)
                      → A x + ¬ A x
                      → List (Σ x ꞉ X , A x)
                      → List (Σ x ꞉ X , A x)
conditionally-prepend A x (inl a) ys = (x , a) ∷ ys
conditionally-prepend A x (inr _) ys = ys


filter' : {X : 𝓤 ̇ }
          (A : X → 𝓥 ̇ )
        → ((x : X) → A x + ¬ A x)
        → List X
        → List (Σ x ꞉ X , A x)
filter' A δ []       = []
filter' A δ (x ∷ xs) = conditionally-prepend A x (δ x) (filter' A δ xs)

filter'-member← : {X : 𝓤 ̇ }
                  (A : X → 𝓥 ̇ )
                  (δ : (x : X) → A x + ¬ A x)
                  (A-is-prop-valued : (x : X) → is-prop (A x))
                  (y : X)
                  (xs : List X)
                  (a : A y)
                → member y xs
                → member (y , a) (filter' A δ xs)
filter'-member← {𝓤} {𝓥} {X} A δ A-is-prop-valued y (x ∷ xs) = h x xs (δ x)
 where
  h : (x : X)
      (xs : List X)
    → (d : A x + ¬ A x)
      (a : A y)
    → member y (x ∷ xs)
    → member (y , a) (conditionally-prepend A x d (filter' A δ xs))
  h x xs (inl b) a in-head = II
   where
    I : member (y , a) ((y , a) ∷ filter' A δ xs)
    I = in-head

    II : member (y , a) ((y , b) ∷ filter' A δ xs)
    II = transport
          (λ - → member (y , a) ((y , -) ∷ filter' A δ xs))
          (A-is-prop-valued y a b)
          I
  h x (x' ∷ xs) (inl b) a (in-tail m) = in-tail (h x' xs (δ x') a m)
  h x xs (inr r) a in-head = 𝟘-elim (r a)
  h x xs (inr x₁) a (in-tail m) = filter'-member← A δ A-is-prop-valued y xs a m

detachable-subtype-of-listed-type-is-listed
 : {X : Type}
 → (A : X → Type)
 → ((x : X) → is-decidable (A x))
 → ((x : X) → is-prop (A x))
 → listed X
 → listed (Σ x ꞉ X , A x)
detachable-subtype-of-listed-type-is-listed {X} A δ A-is-prop-valued (xs , m)
 = filter' A δ xs , γ
 where
  γ : (σ : Σ x ꞉ X , A x) → member σ (filter' A δ xs)
  γ (x , a) = filter'-member← A δ A-is-prop-valued x xs a (m x)

prune-is-listed : (Xt : 𝑻)
                  (q : Path Xt → R)
                  (ϕt : 𝓚 Xt)
                → structure listed Xt
                → structure listed (prune Xt q ϕt)
prune-is-listed [] q ϕt ⟨⟩ = ⟨⟩
prune-is-listed (X ∷ Xf) q (ϕ :: ϕf) (X-is-listed , Xf-is-listed) =
 X'-is-listed :: Xf'-is-listed
 where
  X' : Type
  X' = Σ x ꞉ X , is-optimal-move q ϕ ϕf x

  X'-is-listed : listed X'
  X'-is-listed = detachable-subtype-of-listed-type-is-listed
                  (is-optimal-move q ϕ ϕf)
                  (being-optimal-move-is-decidable q ϕ ϕf)
                  (being-optimal-move-is-prop q ϕ ϕf)
                  X-is-listed

  Xf' : X' → 𝑻
  Xf' (x , o) = prune (Xf x) (subpred q x) (ϕf x)

  Xf'-is-listed : (x' : X') → structure listed (Xf' x')
  Xf'-is-listed (x , o) = prune-is-listed
                           (Xf x)
                           (subpred q x)
                           (ϕf x)
                           (Xf-is-listed x)

optimal-plays' : {Xt : 𝑻}
                 (q : Path Xt → R)
                 (ϕt : 𝓚 Xt)
                 (Xt-is-listed : structure listed Xt)
               → List (Path Xt)
optimal-plays' {Xt} q ϕt Xt-is-listed = xss
 where
  Xt' : 𝑻
  Xt' = prune Xt q ϕt

  xss' : List (Path (prune Xt q ϕt))
  xss' = list-of-paths Xt' (prune-is-listed Xt q ϕt Xt-is-listed)

  xss : List (Path Xt)
  xss = lmap (inclusion q ϕt) xss'

\end{code}

Notice that this way of computing the optimal plays doesn't need the
assumption that the quantifiers are attainable.

TODO. Prove that optimal-plays' lists precisely the optimal plays.
