Tom de Jong, Nicolai Kraus, Fredrik Nordvall Forsberg, Chuangjie Xu.
April 2025.

We implement Robin Grayson's variant of the decreasing list construction of
exponentials, and a proof that it is not, in general, an ordinal, as this would
imply excluded middle.

Grayson's construction is published as [1] which is essentially Chapter IX of
Grayson's PhD thesis [2].

The "concrete" list-based exponentiation that we consider in
Ordinals.Exponentiation.DecreasingList is essentially Grayson's construction,
except that Grayson does not require the base ordinal α to have a trichotomous
least element. In fact, he does not even require α to have a least element and
consequently restricts to those elements x of α for which there exists an a ≺ x.
We shall refer to this condition as "positively non-minimal" as it is a positive
reformulation of non-minimality.

Unfortunately, Grayson's construction does not always yield an ordinal
constructively as we show by a suitable reduction to excluded middle.

However, if α has a trichotomous least element ⊥, then it is straightforward to
show that x : α is positively non-minimal if and only if ⊥ ≺ x, so that
Grayson's construction coincides with our concrete construction (and hence is
always an ordinal).

Grayson moreover claims that his construction satisfies the recursive equation:
   α ^ₒ β ＝ sup (α ^ₒ (β ↓ b) ×ₒ α) ∨ 𝟙ₒ
which we used to define abstract exponentiation in
Ordinals.Exponentiation.Supremum.
Since this recursive equation uniquely specifies the operation ^ₒ, this implies
that Grayson's construction satisfies the equation precisely when it coincides
with abstract exponentiation.
Now, Grayson's construction is easily to seen have a trichotomous least element,
namely the empty list. But given ordinals α and β with least elements, we show
in Ordinals.Exponentiation.Supremum that if the least element of abstract
exponentiation of α by β is trichotomous, then the least element of α must be
too. Hence, the recursive equation cannot hold for Grayson's construction unless
α has a trichotomous least element, in which case the equation holds indeed, as
proved in Ordinals.Exponentiation.RelatingConstructions.

[1] Robin J. Grayson
    Constructive Well-Orderings
    Mathematical Logic Quarterly
    Volume 28, Issue 33-38
    1982
    Pages 495-504
    https://doi.org/10.1002/malq.19820283304

[2] Robin John Grayson
    Intuitionistic Set Theory
    PhD thesis
    University of Oxford
    1978
    https://doi.org/10.5287/ora-azgxayaor

\begin{code}

{-# OPTIONS --safe --without-K --exact-split --lossy-unification #-}

open import UF.Univalence
open import UF.PropTrunc

module Ordinals.Exponentiation.Grayson
       (ua : Univalence)
       (pt : propositional-truncations-exist)
       where

open import UF.ClassicalLogic
open import UF.FunExt
open import UF.UA-FunExt
open import UF.Subsingletons

private
 fe : FunExt
 fe = Univalence-gives-FunExt ua

 fe' : Fun-Ext
 fe' {𝓤} {𝓥} = fe 𝓤 𝓥

 pe : Prop-Ext
 pe = Univalence-gives-Prop-Ext ua

open import MLTT.List
open import MLTT.Plus-Properties
open import MLTT.Spartan

open import UF.Base
open import UF.Equiv
open import UF.Subsingletons-FunExt

open import Ordinals.Arithmetic fe
open import Ordinals.AdditionProperties ua
open import Ordinals.Equivalence
open import Ordinals.Notions
open import Ordinals.OrdinalOfOrdinals ua renaming (_≼_ to _≼OO_)
open import Ordinals.Propositions ua
open import Ordinals.Type
open import Ordinals.Underlying
open import Ordinals.WellOrderArithmetic

open import Ordinals.Exponentiation.TrichotomousLeastElement ua
open import Ordinals.Exponentiation.DecreasingList ua

open PropositionalTruncation pt

\end{code}

\begin{code}

is-positively-non-minimal : {A : 𝓤 ̇  } (R : A → A → 𝓥 ̇  ) → A → 𝓤 ⊔ 𝓥 ̇
is-positively-non-minimal {A = A} R x = ∃ a ꞉ A ,  R a x

\end{code}

In an ordinal with a trichotomous least element ⊥, an element x is positively
non-minimal if and only if ⊥ ≺ x.

\begin{code}

is-positively-non-minimal-iff-positive
 : (α : Ordinal 𝓤)
 → ((⊥ , τ) : has-trichotomous-least-element α)
 → (x : ⟨ α ⟩) → is-positively-non-minimal (underlying-order α) x ↔ ⊥ ≺⟨ α ⟩ x
is-positively-non-minimal-iff-positive α (⊥ , τ) x =
 (∥∥-rec (Prop-valuedness α ⊥ x) I) , (λ l → ∣ ⊥ , l ∣)
 where
   I : (Σ a ꞉ ⟨ α ⟩ , a ≺⟨ α ⟩ x)
     → ⊥ ≺⟨ α ⟩ x
   I (a , l) = I' (τ a)
    where
     I' : (⊥ ＝ a) + (⊥ ≺⟨ α ⟩ a) → ⊥ ≺⟨ α ⟩ x
     I' (inl refl) = l
     I' (inr k) = Transitivity α ⊥ a x k l

\end{code}

The type of Grayson lists on ordinals α and β is the type of lists over α ×ₒ β
such that the list is (strictly) decreasing in the second component and such
that all the elements in the first component are positively non-minimal.
That is, an element looks like
   (a₀ , b₀) , (a₁ , b₁) , ... , (aₙ , bₙ)
with bₙ ≺ ... ≺ b₁ ≺ b₀ and each aᵢ is positively non-minimal.

We define it a bit more generally below: instead of two ordinals, we just assume
two types and a binary relations on each of them, imposing additional
assumptions only as we need them.

\begin{code}

module _ {A B : 𝓤 ̇  } (R : A → A → 𝓥 ̇  ) (R' : B → B → 𝓥 ̇  ) where

 is-grayson : List (A × B) → 𝓤 ⊔ 𝓥 ̇
 is-grayson l = is-decreasing R' (map pr₂ l)
              × All (is-positively-non-minimal R) (map pr₁ l)

 is-grayson-is-prop : is-prop-valued R'
                    → is-prop-valued-family is-grayson
 is-grayson-is-prop p' l =
  ×-is-prop (is-decreasing-is-prop R' p' (map pr₂ l))
            (All-is-prop _ (λ x → ∃-is-prop) (map pr₁ l))

 GraysonList : 𝓤 ⊔ 𝓥 ̇
 GraysonList = Σ l ꞉ List (A × B) , is-grayson l

 GraysonList-list : GraysonList → List (A × B)
 GraysonList-list = pr₁

 to-GraysonList-＝ : is-prop-valued R'
                   → {l l' : GraysonList}
                   → GraysonList-list l ＝ GraysonList-list l' → l ＝ l'
 to-GraysonList-＝ p' = to-subtype-＝ (is-grayson-is-prop p')

 Grayson-order : GraysonList → GraysonList → 𝓤 ⊔ 𝓥 ̇
 Grayson-order (l , _) (l' , _) = lex (times.order R R') l l'

 GraysonList-⊥ : GraysonList
 GraysonList-⊥ = [] , ([]-decr , [])

\end{code}

We defined is-trichotomous-least for ordinals only, so we inline that definition
in the following.

\begin{code}

 GraysonList-has-trichotomous-least-element
  : is-prop-valued R'
  → (l : GraysonList) → (GraysonList-⊥ ＝ l) + (Grayson-order GraysonList-⊥ l)
 GraysonList-has-trichotomous-least-element p ([] , g) =
  inl (to-GraysonList-＝ p refl)
 GraysonList-has-trichotomous-least-element p ((_ ∷ l) , g) = inr []-lex

\end{code}

We now fix B = 𝟙ₒ, in order to derive properties on the positively
non-minimal elements of A from properties on GraysonList A B.

\begin{code}

module _ {A : 𝓤 ̇  } (R : A → A → 𝓥 ̇  ) where

 GList : 𝓤 ⊔ 𝓥 ̇
 GList = GraysonList {B = 𝟙} R (λ _ _ → 𝟘)

 A⁺ = Σ a ꞉ A , is-positively-non-minimal R a

 R⁺ : A⁺ → A⁺ → 𝓥 ̇
 R⁺ (a , _) (a' , _) = R a a'

 sing : 𝟙 {𝓤 = 𝓤} + A⁺ → GList
 sing (inl ⋆) = ([] , []-decr , [])
 sing (inr (a , p)) = ([ (a , ⋆) ] , sing-decr , (p ∷ []))

 sing⁻¹ : GList → 𝟙 {𝓤 = 𝓤} + A⁺
 sing⁻¹ ([] , _) = inl ⋆
 sing⁻¹ (((a , ⋆) ∷ _) , (q , (p ∷ _))) = inr (a , p)

 sing-retraction : sing⁻¹ ∘ sing ∼ id
 sing-retraction (inl ⋆) = refl
 sing-retraction (inr (a , p)) = refl

 sing-section : sing ∘ sing⁻¹ ∼ id
 sing-section ([] , []-decr , []) = refl
 sing-section ((a , ⋆ ∷ []) , sing-decr , (p ∷ [])) = refl
 sing-section ((a , ⋆ ∷ a' , ⋆ ∷ l) , many-decr r q , (p ∷ ps)) = 𝟘-elim r

 sing-is-equiv : is-equiv sing
 sing-is-equiv = qinvs-are-equivs sing (sing⁻¹ , sing-retraction , sing-section)

 _≺_ : GList → GList →  𝓤 ⊔ 𝓥 ̇
 _≺_ = Grayson-order {B = 𝟙} R (λ _ _ → 𝟘)

 sing⁺ : (x y : A⁺) → R⁺ x y → sing (inr x) ≺ sing (inr y)
 sing⁺ x y p = head-lex (inr (refl , p))

\end{code}

Assuming that the order on Grayson lists is a well-order, so is the order on A⁺.

\begin{code}

 R⁺-propvalued : is-prop-valued _≺_ → is-prop-valued R⁺
 R⁺-propvalued prop x y p q = ap pr₂ II
  where
   I : head-lex (inr (refl , p)) ＝ head-lex (inr (refl , q))
   I = prop (sing (inr x)) (sing (inr y)) (sing⁺ x y p) (sing⁺ x y q)

   II : (refl , p) ＝ (refl , q)
   II = inr-lc (head-lex-lc _ _ _ I)

 R⁺-wellfounded : is-well-founded _≺_ → is-well-founded R⁺
 R⁺-wellfounded wf x = I x (wf (sing (inr x)))
  where
   I : (x : A⁺) → is-accessible _≺_ (sing (inr x)) → is-accessible R⁺ x
   I x (acc f) = acc (λ y p → I y (f (sing (inr y)) (sing⁺ y x p)))

 R⁺-extensional : is-extensional _≺_ → is-extensional R⁺
 R⁺-extensional ext x y p q = inr-lc III
  where
   I : (x y : A⁺)
     → ((z : A⁺) → R⁺ z x → R⁺ z y)
     → (l : GList) → l ≺ sing (inr x) → l ≺ sing (inr y)
   I x y e l []-lex = []-lex
   I x y e ((a , ⋆ ∷ l') , _ , (q ∷ _)) (head-lex (inr (_ , r))) =
    head-lex (inr (refl , e (a , q) r))

   II : sing (inr x) ＝ sing (inr y)
   II = ext (sing (inr x)) (sing (inr y)) (I x y p) (I y x q)

   III = inr x ＝⟨ sing-retraction (inr x) ⁻¹ ⟩
         sing⁻¹ (sing (inr x)) ＝⟨ ap sing⁻¹ II ⟩
         sing⁻¹ (sing (inr y)) ＝⟨ sing-retraction (inr y) ⟩
         inr y ∎

 R⁺-transitive : is-transitive _≺_ → is-transitive R⁺
 R⁺-transitive trans a₀ a₁ a₂ p q = II I
  where
   I : sing (inr a₀) ≺ sing (inr a₂)
   I = trans (sing (inr a₀)) (sing (inr a₁)) (sing (inr a₂))
             (sing⁺ a₀ a₁ p) (sing⁺ a₁ a₂ q)

   II : sing (inr a₀) ≺ sing (inr a₂) → R⁺ a₀ a₂
   II (head-lex (inr (_ , r))) = r

 R⁺-wellorder : is-well-order _≺_ → is-well-order R⁺
 R⁺-wellorder (p , w , e , t) =
  R⁺-propvalued p , R⁺-wellfounded w , R⁺-extensional e , R⁺-transitive t

\end{code}

However, it is a constructive taboo that the subtype of positively non-minimal
elements is always an ordinal, with essentially the same proof as for
subtype-of-positive-elements-an-ordinal-implies-EM in
Ordinals.Exponentiation.Taboos.

\begin{code}

subtype-of-positively-non-minimal-elements-an-ordinal-implies-EM
 : ((α : Ordinal (𝓤 ⁺⁺))
    → is-well-order
       (subtype-order α (is-positively-non-minimal (underlying-order α))))
 → EM 𝓤
subtype-of-positively-non-minimal-elements-an-ordinal-implies-EM {𝓤} hyp = III
 where
  open import Ordinals.OrdinalOfTruthValues fe 𝓤 pe
  open import UF.DiscreteAndSeparated
  open import UF.SubtypeClassifier

  _<_ = subtype-order (OO (𝓤 ⁺)) (is-positively-non-minimal _⊲_)

  <-is-prop-valued : is-prop-valued _<_
  <-is-prop-valued =
   subtype-order-is-prop-valued (OO (𝓤 ⁺)) (is-positively-non-minimal _⊲_)

  hyp' : is-extensional' _<_
  hyp' = extensional-gives-extensional' _<_
          (extensionality _<_ (hyp (OO (𝓤 ⁺))))

  Ord⁺ = Σ α ꞉ Ordinal (𝓤 ⁺) , is-positively-non-minimal _⊲_ α

  Ωₚ : Ord⁺
  Ωₚ = Ωₒ , ∣ 𝟘ₒ , ⊥ , eqtoidₒ (ua (𝓤 ⁺)) fe' 𝟘ₒ (Ωₒ ↓ ⊥)
                               (≃ₒ-trans 𝟘ₒ 𝟘ₒ (Ωₒ ↓ ⊥) II I) ∣
   where
    I : 𝟘ₒ ≃ₒ Ωₒ ↓ ⊥
    I = ≃ₒ-sym (Ωₒ ↓ ⊥) 𝟘ₒ (Ωₒ↓-is-id ua ⊥)

    II : 𝟘ₒ {𝓤 ⁺} ≃ₒ 𝟘ₒ {𝓤}
    II = only-one-𝟘ₒ

  𝟚ₚ : Ord⁺
  𝟚ₚ = 𝟚ₒ , ∣ 𝟘ₒ , inl ⋆ , (prop-ordinal-↓ 𝟙-is-prop ⋆ ⁻¹ ∙ +ₒ-↓-left ⋆) ∣

  I : (γ : Ord⁺) → (γ < Ωₚ ↔ γ < 𝟚ₚ)
  I (γ , p) = ∥∥-rec (↔-is-prop fe' fe' (<-is-prop-valued (γ , p) Ωₚ)
                                        (<-is-prop-valued (γ , p) 𝟚ₚ)) I' p
   where
    I' : Σ (λ a → a ⊲ γ) → ((γ , p) < Ωₚ) ↔ ((γ , p) < 𝟚ₚ)
    I' (.(γ ↓ c') , (c' , refl)) = I₁ , I₂
     where
      I₁ : ((γ , p) < Ωₚ) → ((γ , p) < 𝟚ₚ)
      I₁ (P , refl) =
       (inr ⋆ , eqtoidₒ (ua (𝓤 ⁺)) fe' _ _ (≃ₒ-trans (Ωₒ ↓ P) Pₒ (𝟚ₒ ↓ inr ⋆) e₁ e₂))
        where
         Pₒ = prop-ordinal (P holds) (holds-is-prop P)

         e₁ : (Ωₒ ↓ P) ≃ₒ Pₒ
         e₁ = Ωₒ↓-is-id ua P

         e₂ : Pₒ ≃ₒ 𝟚ₒ ↓ inr ⋆
         e₂ = transport⁻¹ (Pₒ ≃ₒ_) (successor-lemma-right 𝟙ₒ)
                          ((prop-ordinal-≃ₒ (holds-is-prop P) 𝟙-is-prop
                                            (λ _ → ⋆)
                                            (λ _ → ≃ₒ-to-fun (Ωₒ ↓ P) Pₒ e₁ c')))

      I₂ : ((γ , p) < 𝟚ₚ) → ((γ , p) < Ωₚ)
      I₂ l = ⊲-⊴-gives-⊲ γ 𝟚ₒ Ωₒ l (𝟚ₒ-leq-Ωₒ ua)

  II : Ω 𝓤 ＝ ⟨ 𝟚ₒ ⟩
  II = ap (⟨_⟩ ∘ pr₁) (hyp' Ωₚ 𝟚ₚ I)

  III : EM 𝓤
  III = Ω-discrete-gives-EM fe' pe
         (equiv-to-discrete
           (idtoeq (𝟙 + 𝟙) (Ω 𝓤) (II ⁻¹))
           (+-is-discrete 𝟙-is-discrete 𝟙-is-discrete))

\end{code}

Hence, putting everything together, it is also a constructive taboo
that GraysonList α β is an ordinal whenever α and β are.

\begin{code}

GraysonList-always-ordinal-implies-EM
 : ((α β : Ordinal (𝓤 ⁺⁺))
   → is-well-order (Grayson-order (underlying-order α) (underlying-order β)))
 → EM 𝓤
GraysonList-always-ordinal-implies-EM {𝓤} hyp = II
 where
  I : (α : Ordinal (𝓤 ⁺⁺))
    → is-well-order
       (subtype-order α (is-positively-non-minimal (underlying-order α)))
  I α = R⁺-wellorder (underlying-order α) (hyp α 𝟙ₒ)

  II : EM 𝓤
  II = subtype-of-positively-non-minimal-elements-an-ordinal-implies-EM I

\end{code}
