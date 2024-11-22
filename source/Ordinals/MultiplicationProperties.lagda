Fredrik Nordvall Forsberg, 13 November 2023.
In collaboration with Tom de Jong, Nicolai Kraus and Chuangjie Xu.

Minor updates 9 and 11 September, and 1 November 2024.

We prove several properties of ordinal multiplication, including that it
preserves suprema of ordinals and that it enjoys a left-cancellation property.

\begin{code}

{-# OPTIONS --safe --without-K --lossy-unification #-}

open import UF.Univalence

module Ordinals.MultiplicationProperties
       (ua : Univalence)
       where

open import UF.Base
open import UF.Equiv
open import UF.FunExt
open import UF.Subsingletons
open import UF.Subsingletons-FunExt
open import UF.UA-FunExt
open import UF.ClassicalLogic

private
 fe : FunExt
 fe = Univalence-gives-FunExt ua

 fe' : Fun-Ext
 fe' {𝓤} {𝓥} = fe 𝓤 𝓥

open import MLTT.Spartan
open import MLTT.Plus-Properties

open import Ordinals.Arithmetic fe
open import Ordinals.Equivalence
open import Ordinals.Maps
open import Ordinals.OrdinalOfOrdinals ua
open import Ordinals.Type
open import Ordinals.Underlying
open import Ordinals.AdditionProperties ua

×ₒ-𝟘ₒ-right : (α : Ordinal 𝓤) → α ×ₒ 𝟘ₒ {𝓥} ＝ 𝟘ₒ
×ₒ-𝟘ₒ-right α = ⊴-antisym _ _
                 (to-⊴ (α ×ₒ 𝟘ₒ) 𝟘ₒ (λ (a , b) → 𝟘-elim b))
                 (𝟘ₒ-least-⊴ (α ×ₒ 𝟘ₒ))

×ₒ-𝟘ₒ-left : (α : Ordinal 𝓤) → 𝟘ₒ {𝓥} ×ₒ α ＝ 𝟘ₒ
×ₒ-𝟘ₒ-left α = ⊴-antisym _ _
                (to-⊴ (𝟘ₒ ×ₒ α) 𝟘ₒ (λ (b , a) → 𝟘-elim b))
                (𝟘ₒ-least-⊴ (𝟘ₒ ×ₒ α))

𝟙ₒ-left-neutral-×ₒ : (α : Ordinal 𝓤) → 𝟙ₒ {𝓤} ×ₒ α ＝ α
𝟙ₒ-left-neutral-×ₒ {𝓤} α = eqtoidₒ (ua _) fe' _ _
                            (f , f-order-preserving ,
                             f-is-equiv , g-order-preserving)
 where
  f : 𝟙 × ⟨ α ⟩ → ⟨ α ⟩
  f = pr₂

  g : ⟨ α ⟩ → 𝟙 × ⟨ α ⟩
  g = ( ⋆ ,_)

  f-order-preserving : is-order-preserving (𝟙ₒ {𝓤} ×ₒ α) α f
  f-order-preserving x y (inl p) = p

  f-is-equiv : is-equiv f
  f-is-equiv = qinvs-are-equivs f (g , (λ _ → refl) , (λ _ → refl))

  g-order-preserving : is-order-preserving α (𝟙ₒ {𝓤} ×ₒ α) g
  g-order-preserving x y p = inl p

𝟙ₒ-right-neutral-×ₒ : (α : Ordinal 𝓤) → α ×ₒ 𝟙ₒ {𝓤} ＝ α
𝟙ₒ-right-neutral-×ₒ {𝓤} α = eqtoidₒ (ua _) fe' _ _
                             (f , f-order-preserving ,
                              f-is-equiv , g-order-preserving)
 where
  f : ⟨ α ⟩ × 𝟙 → ⟨ α ⟩
  f = pr₁

  g : ⟨ α ⟩ → ⟨ α ⟩ × 𝟙
  g = (_, ⋆ )

  f-order-preserving : is-order-preserving (α ×ₒ 𝟙ₒ {𝓤}) α f
  f-order-preserving x y (inr (refl , p)) = p

  f-is-equiv : is-equiv f
  f-is-equiv = qinvs-are-equivs f (g , (λ _ → refl) , (λ _ → refl))

  g-order-preserving : is-order-preserving α (α ×ₒ 𝟙ₒ {𝓤}) g
  g-order-preserving x y p = inr (refl , p)

\end{code}

Because we use --lossy-unification to speed up typechecking we have to
explicitly mention the universes in the lemma below; using them as variables (as
usual) results in a unification error.

\begin{code}

×ₒ-assoc : {𝓤 𝓥 𝓦 : Universe}
           (α : Ordinal 𝓤) (β : Ordinal 𝓥) (γ : Ordinal 𝓦)
         → (α ×ₒ β) ×ₒ γ ＝ α ×ₒ (β ×ₒ γ)
×ₒ-assoc α β γ =
 eqtoidₒ (ua _) fe' ((α  ×ₒ β) ×ₒ γ) (α  ×ₒ (β ×ₒ γ))
  (f , order-preserving-reflecting-equivs-are-order-equivs
   ((α  ×ₒ β) ×ₒ γ) (α  ×ₒ (β ×ₒ γ))
   f f-equiv f-preserves-order f-reflects-order)
  where
   f : ⟨ (α ×ₒ β) ×ₒ γ ⟩ → ⟨ α ×ₒ (β ×ₒ γ) ⟩
   f ((a , b) , c) = (a , (b , c))

   g : ⟨ α ×ₒ (β ×ₒ γ) ⟩ → ⟨ (α ×ₒ β) ×ₒ γ ⟩
   g (a , (b , c)) = ((a , b) , c)

   f-equiv : is-equiv f
   f-equiv = qinvs-are-equivs f (g , (λ x → refl) , (λ x → refl))

   f-preserves-order : is-order-preserving  ((α  ×ₒ β) ×ₒ γ) (α  ×ₒ (β ×ₒ γ)) f
   f-preserves-order _ _ (inl p) = inl (inl p)
   f-preserves-order _ _ (inr (r , inl p)) = inl (inr (r , p))
   f-preserves-order _ _ (inr (r , inr (u , q))) = inr (to-×-＝ u r , q)

   f-reflects-order : is-order-reflecting ((α  ×ₒ β) ×ₒ γ) (α  ×ₒ (β ×ₒ γ)) f
   f-reflects-order _ _ (inl (inl p)) = inl p
   f-reflects-order _ _ (inl (inr (r , q))) = inr (r , (inl q))
   f-reflects-order _ _ (inr (refl , q)) = inr (refl , (inr (refl , q)))

\end{code}

The lemma below is as general as possible in terms of universe parameters
because addition requires its arguments to come from the same universe, at least
at present.

\begin{code}

×ₒ-distributes-+ₒ-right : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
                        → α ×ₒ (β +ₒ γ) ＝ (α ×ₒ β) +ₒ (α ×ₒ γ)
×ₒ-distributes-+ₒ-right α β γ = eqtoidₒ (ua _) fe' _ _
                                 (f , f-order-preserving ,
                                  f-is-equiv , g-order-preserving)
 where
  f : ⟨ α ×ₒ (β +ₒ γ) ⟩ → ⟨ (α ×ₒ β) +ₒ (α ×ₒ γ) ⟩
  f (a , inl b) = inl (a , b)
  f (a , inr c) = inr (a , c)

  g : ⟨ (α ×ₒ β) +ₒ (α ×ₒ γ) ⟩ → ⟨ α ×ₒ (β +ₒ γ) ⟩
  g (inl (a , b)) = a , inl b
  g (inr (a , c)) = a , inr c

  f-order-preserving : is-order-preserving _ _ f
  f-order-preserving (a , inl b) (a' , inl b') (inl p) = inl p
  f-order-preserving (a , inl b) (a' , inr c') (inl p) = ⋆
  f-order-preserving (a , inr c) (a' , inr c') (inl p) = inl p
  f-order-preserving (a , inl b) (a' , inl .b) (inr (refl , q)) = inr (refl , q)
  f-order-preserving (a , inr c) (a' , inr .c) (inr (refl , q)) = inr (refl , q)

  f-is-equiv : is-equiv f
  f-is-equiv = qinvs-are-equivs f (g , η , ε)
   where
    η : g ∘ f ∼ id
    η (a , inl b) = refl
    η (a , inr c) = refl

    ε : f ∘ g ∼ id
    ε (inl (a , b)) = refl
    ε (inr (a , c)) = refl

  g-order-preserving : is-order-preserving _ _ g
  g-order-preserving (inl (a , b)) (inl (a' , b')) (inl p) = inl p
  g-order-preserving (inl (a , b)) (inl (a' , .b)) (inr (refl , q)) =
   inr (refl , q)
  g-order-preserving (inl (a , b)) (inr (a' , c')) p = inl ⋆
  g-order-preserving (inr (a , c)) (inr (a' , c')) (inl p) = inl p
  g-order-preserving (inr (a , c)) (inr (a' , c')) (inr (refl , q)) =
   inr (refl , q)

\end{code}

The following characterizes the initial segments of a product and is rather
useful when working with simulations between products.

\begin{code}

×ₒ-↓ : (α β : Ordinal 𝓤)
     → {a : ⟨ α ⟩} {b : ⟨ β ⟩}
     → (α ×ₒ β) ↓ (a , b) ＝ (α ×ₒ (β ↓ b)) +ₒ (α ↓ a)
×ₒ-↓ α β {a} {b} = eqtoidₒ (ua _) fe' _ _ (f , f-order-preserving ,
                                           f-is-equiv , g-order-preserving)
 where
  f : ⟨ (α ×ₒ β) ↓ (a , b) ⟩ → ⟨ (α ×ₒ (β ↓ b)) +ₒ (α ↓ a) ⟩
  f ((x , y) , inl p) = inl (x , (y , p))
  f ((x , y) , inr (r , q)) = inr (x , q)

  g : ⟨ (α ×ₒ (β ↓ b)) +ₒ (α ↓ a) ⟩ → ⟨ (α ×ₒ β) ↓ (a , b) ⟩
  g (inl (x , y , p)) = (x , y) , inl p
  g (inr (x , q)) = (x , b) , inr (refl , q)

  f-order-preserving : is-order-preserving _ _ f
  f-order-preserving ((x , y) , inl p) ((x' , y') , inl p') (inl l) = inl l
  f-order-preserving ((x , y) , inl p) ((x' , _)  , inl p') (inr (refl , l)) =
   inr ((ap (y ,_) (Prop-valuedness β _ _ p p')) , l)
  f-order-preserving ((x , y) , inl p) ((x' , y') , inr (r' , q')) l = ⋆
  f-order-preserving ((x , y) , inr (refl , q)) ((x' , y') , inl p') (inl l) =
   𝟘-elim (irrefl β y (Transitivity β _ _ _ l p'))
  f-order-preserving ((x , y) , inr (refl , q))
                     ((x' , _)  , inl p') (inr (refl , l)) = 𝟘-elim
                                                              (irrefl β y p')
  f-order-preserving ((x , y) , inr (refl , q))
                     ((x' , _)  , inr (refl , q')) (inl l) = 𝟘-elim
                                                              (irrefl β y l)
  f-order-preserving ((x , y) , inr (refl , q))
                     ((x' , _)  , inr (refl , q')) (inr (_ , l)) = l

  f-is-equiv : is-equiv f
  f-is-equiv = qinvs-are-equivs f (g , η , ε)
   where
    η : g ∘ f ∼ id
    η ((x , y) , inl p) = refl
    η ((x , y) , inr (refl , q)) = refl

    ε : f ∘ g ∼ id
    ε (inl (x , y)) = refl
    ε (inr x) = refl

  g-order-preserving : is-order-preserving _ _ g
  g-order-preserving (inl (x , y , p)) (inl (x' , y' , p')) (inl l) = inl l
  g-order-preserving (inl (x , y , p)) (inl (x' , y' , p')) (inr (refl , l)) =
   inr (refl , l)
  g-order-preserving (inl (x , y , p)) (inr (x' , q')) _ = inl p
  g-order-preserving (inr (x , q))     (inr (x' , q')) l = inr (refl , l)

\end{code}

We now prove several useful facts about (bounded) simulations between products.

\begin{code}

×ₒ-increasing-on-right : (α β γ : Ordinal 𝓤)
                       → 𝟘ₒ ⊲ α
                       → β ⊲ γ
                       → (α ×ₒ β) ⊲ (α ×ₒ γ)
×ₒ-increasing-on-right α β γ (a , p) (c , q) = (a , c) , I
 where
  I = α ×ₒ β                    ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ β) ⁻¹ ⟩
      (α ×ₒ β) +ₒ 𝟘ₒ            ＝⟨ ap₂ (λ -₁ -₂ → (α ×ₒ -₁) +ₒ -₂) q p ⟩
      (α ×ₒ (γ ↓ c)) +ₒ (α ↓ a) ＝⟨ ×ₒ-↓ α γ ⁻¹ ⟩
      (α ×ₒ γ) ↓ (a , c)        ∎

×ₒ-right-monotone-⊴ : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
                    → β ⊴ γ
                    → (α ×ₒ β) ⊴ (α ×ₒ γ)
×ₒ-right-monotone-⊴ α β γ (g , sim-g) = f , f-initial-segment ,
                                            f-order-preserving
 where
   f : ⟨ α ×ₒ β ⟩ → ⟨ α ×ₒ γ ⟩
   f (a , b) = a , g b

   f-initial-segment : is-initial-segment (α ×ₒ β) (α ×ₒ γ) f
   f-initial-segment (a , b) (a' , c') (inl l) = (a' , b') , inl k , ap (a' ,_) q
    where
     I : Σ b' ꞉ ⟨ β ⟩ , b' ≺⟨ β ⟩ b × (g b' ＝ c')
     I = simulations-are-initial-segments β γ g sim-g b c' l
     b' = pr₁ I
     k = pr₁ (pr₂ I)
     q = pr₂ (pr₂ I)
   f-initial-segment (a , b) (a' , c') (inr (refl , q)) =
    (a' , b) , inr (refl , q) , refl

   f-order-preserving : is-order-preserving (α ×ₒ β) (α ×ₒ γ) f
   f-order-preserving (a , b) (a' , b') (inl p) =
    inl (simulations-are-order-preserving β γ g sim-g b b' p)
   f-order-preserving (a , b) (a' , b') (inr (refl , q)) = inr (refl , q)

×ₒ-≼-left : (α : Ordinal 𝓤) (β : Ordinal 𝓥)
            {a a' : ⟨ α ⟩} {b : ⟨ β ⟩}
          → a ≼⟨ α ⟩ a'
          → (a , b) ≼⟨ α ×ₒ β ⟩ (a' , b)
×ₒ-≼-left α β p (a₀ , b₀) (inl r) = inl r
×ₒ-≼-left α β p (a₀ , b₀) (inr (eq , r)) = inr (eq , p a₀ r)

\end{code}

Multiplication satisfies the expected recursive equations (which
classically define ordinal multiplication): zero is fixed by multiplication
(this is ×ₒ-𝟘ₒ-right above), multiplication for successors is repeated addition
and multiplication preserves suprema.

\begin{code}

×ₒ-successor : (α β : Ordinal 𝓤) → α ×ₒ (β +ₒ 𝟙ₒ) ＝ (α ×ₒ β) +ₒ α
×ₒ-successor α β =
  α ×ₒ (β +ₒ 𝟙ₒ)          ＝⟨ ×ₒ-distributes-+ₒ-right α β 𝟙ₒ ⟩
  ((α ×ₒ β) +ₒ (α ×ₒ 𝟙ₒ)) ＝⟨ ap ((α ×ₒ β) +ₒ_) (𝟙ₒ-right-neutral-×ₒ α)  ⟩
  (α ×ₒ β) +ₒ α           ∎

open import UF.PropTrunc
open import UF.Size

module _ (pt : propositional-truncations-exist)
         (sr : Set-Replacement pt)
       where

 open import Ordinals.OrdinalOfOrdinalsSuprema ua
 open suprema pt sr
 open PropositionalTruncation pt

 ×ₒ-preserves-suprema : (α : Ordinal 𝓤) {I : 𝓤 ̇ } (β : I → Ordinal 𝓤)
                      → α ×ₒ sup β ＝ sup (λ i → α ×ₒ β i)
 ×ₒ-preserves-suprema {𝓤} α {I} β = ⊴-antisym (α ×ₒ sup β) (sup (λ i → α ×ₒ β i)) ⦅1⦆ ⦅2⦆
  where
   ⦅2⦆ : sup (λ i → α ×ₒ β i) ⊴ (α ×ₒ sup β)
   ⦅2⦆ = sup-is-lower-bound-of-upper-bounds (λ i → α ×ₒ β i) (α ×ₒ sup β)
          (λ i → ×ₒ-right-monotone-⊴ α (β i) (sup β) (sup-is-upper-bound β i))

   ⦅1⦆ : (α ×ₒ sup β) ⊴ sup (λ i → α ×ₒ β i)
   ⦅1⦆ = ≼-gives-⊴ (α ×ₒ sup β) (sup (λ i → α ×ₒ β i)) ⦅1⦆-I
    where
     ⦅1⦆-I : (γ : Ordinal 𝓤) → γ ⊲ (α ×ₒ sup β) → γ ⊲ sup (λ i → α ×ₒ β i)
     ⦅1⦆-I _ ((a , y) , refl) = ⦅1⦆-III
      where
       ⦅1⦆-II : (Σ i ꞉ I , Σ b ꞉ ⟨ β i ⟩ , sup β ↓ y ＝ (β i) ↓ b)
              → ((α ×ₒ sup β) ↓ (a , y)) ⊲ sup (λ j → α ×ₒ β j)
       ⦅1⦆-II (i , b , e) = σ (a , b) , eq
        where
         σ : ⟨ α ×ₒ β i ⟩ → ⟨ sup (λ j → α ×ₒ β j) ⟩
         σ = [ α ×ₒ β i , sup (λ j → α ×ₒ β j) ]⟨ sup-is-upper-bound _ i ⟩

         eq = (α ×ₒ sup β) ↓ (a , y)           ＝⟨ ×ₒ-↓ α (sup β) ⟩
              (α ×ₒ (sup β ↓ y)) +ₒ (α ↓ a)    ＝⟨ eq₁ ⟩
              (α ×ₒ (β i ↓ b)) +ₒ (α ↓ a)      ＝⟨ ×ₒ-↓ α (β i) ⁻¹ ⟩
              (α ×ₒ β i) ↓ (a , b)             ＝⟨ eq₂ ⟩
              sup (λ j → α ×ₒ β j) ↓ σ (a , b) ∎
          where
           eq₁ = ap (λ - → ((α ×ₒ -) +ₒ (α ↓ a))) e
           eq₂ = (initial-segment-of-sup-at-component
                  (λ j → α ×ₒ β j) i (a , b)) ⁻¹

       ⦅1⦆-III : ((α ×ₒ sup β) ↓ (a , y)) ⊲ sup (λ i → α ×ₒ β i)
       ⦅1⦆-III = ∥∥-rec (⊲-is-prop-valued _ _) ⦅1⦆-II
                  (initial-segment-of-sup-is-initial-segment-of-some-component
                    β y)

\end{code}

11 September 2024, added by Tom de Jong following a question by Martin Escardo.

The equations for successor and suprema uniquely specify the multiplication
operation even though they are not constructively sufficient to define it.

\begin{code}

 private
  successor-equation : (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) → 𝓤 ⁺ ̇
  successor-equation {𝓤} _⊗_ =
   (α β : Ordinal 𝓤) → α ⊗ (β +ₒ 𝟙ₒ) ＝ (α ⊗ β) +ₒ α

  suprema-equation : (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) → 𝓤 ⁺ ̇
  suprema-equation {𝓤} _⊗_ =
   (α : Ordinal 𝓤) (I : 𝓤 ̇  ) (β : I → Ordinal 𝓤)
    → α ⊗ (sup β) ＝ sup (λ i → α ⊗ β i)

  recursive-equation : (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) → 𝓤 ⁺ ̇
  recursive-equation {𝓤} _⊗_ =
   (α β : Ordinal 𝓤) → α ⊗ β ＝ sup (λ b → (α ⊗ (β ↓ b)) +ₒ α)

  successor-and-suprema-equations-give-recursive-equation
   : (_⊗_ : Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤)
   → successor-equation _⊗_
   → suprema-equation _⊗_
   → recursive-equation _⊗_
  successor-and-suprema-equations-give-recursive-equation
   _⊗_ ⊗-succ ⊗-sup α β = α ⊗ β                           ＝⟨ I   ⟩
                          (α ⊗ sup (λ b → (β ↓ b) +ₒ 𝟙ₒ)) ＝⟨ II  ⟩
                          sup (λ b → α ⊗ ((β ↓ b) +ₒ 𝟙ₒ)) ＝⟨ III ⟩
                          sup (λ b → (α ⊗ (β ↓ b)) +ₒ α)  ∎
    where
     I   = ap (α ⊗_) (supremum-of-successors-of-initial-segments pt sr β)
     II  = ⊗-sup α ⟨ β ⟩ (λ b → (β ↓ b) +ₒ 𝟙ₒ)
     III = ap sup (dfunext fe' (λ b → ⊗-succ α (β ↓ b)))

 ×ₒ-recursive-equation : recursive-equation {𝓤} _×ₒ_
 ×ₒ-recursive-equation =
  successor-and-suprema-equations-give-recursive-equation
    _×ₒ_ ×ₒ-successor (λ α _ β → ×ₒ-preserves-suprema α β)

 ×ₒ-is-uniquely-specified'
  : (_⊗_ : Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤)
  → recursive-equation _⊗_
  → (α β : Ordinal 𝓤) → α ⊗ β ＝ α ×ₒ β
 ×ₒ-is-uniquely-specified' {𝓤} _⊗_ ⊗-rec α =
  transfinite-induction-on-OO (λ - → (α ⊗ -) ＝ (α ×ₒ -)) I
   where
    I : (β : Ordinal 𝓤)
      → ((b : ⟨ β ⟩) → (α ⊗ (β ↓ b)) ＝ (α ×ₒ (β ↓ b)))
      → (α ⊗ β) ＝ (α ×ₒ β)
    I β IH = α ⊗ β                            ＝⟨ II  ⟩
             sup (λ b → (α ⊗ (β ↓ b)) +ₒ α)   ＝⟨ III ⟩
             sup (λ b → (α ×ₒ (β ↓ b)) +ₒ α)  ＝⟨ IV  ⟩
             α ×ₒ β                           ∎
     where
      II  = ⊗-rec α β
      III = ap sup (dfunext fe' (λ b → ap (_+ₒ α) (IH b)))
      IV  = ×ₒ-recursive-equation α β ⁻¹

 ×ₒ-is-uniquely-specified
  : ∃! _⊗_ ꞉ (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) ,
     (successor-equation _⊗_) × (suprema-equation _⊗_)
 ×ₒ-is-uniquely-specified {𝓤} =
  (_×ₒ_ , (×ₒ-successor , (λ α _ β → ×ₒ-preserves-suprema α β))) ,
  (λ (_⊗_ , ⊗-succ , ⊗-sup) →
   to-subtype-＝
    (λ F → ×-is-prop (Π₂-is-prop fe'
                       (λ _ _ → underlying-type-is-set fe (OO 𝓤)))
                     (Π₃-is-prop fe'
                       (λ _ _ _ → underlying-type-is-set fe (OO 𝓤))))
    (dfunext fe'
      (λ α → dfunext fe'
       (λ β →
        (×ₒ-is-uniquely-specified' _⊗_
          (successor-and-suprema-equations-give-recursive-equation
            _⊗_ ⊗-succ ⊗-sup)
        α β) ⁻¹))))

\end{code}

The above should be contrasted to the situation for addition where we do not
know how to prove such a result since only *inhabited* suprema are preserved by
addition.

Added 17 September 2024 by Fredrik Nordvall Forsberg:

Multiplication being monotone in the left argument is a constructive taboo.

Addition 22 November 2024: monotonicity in the left argument is
equivalent to Excluded Middle.

\begin{code}

×ₒ-minimal : (α : Ordinal 𝓤)(β : Ordinal 𝓥)
                   → (a₀ : ⟨ α ⟩) → (b₀ : ⟨ β ⟩)
                   → is-least α a₀ → is-least β b₀
                   → is-minimal (α ×ₒ β) (a₀ , b₀)
×ₒ-minimal α β a₀ b₀ a₀-least b₀-least (a , b) (inl l)
 = irrefl β b (b₀-least b b l)
×ₒ-minimal α β a₀ b₀ a₀-least b₀-least (a , b) (inr (refl , l))
 = irrefl α a (a₀-least a a l)

×ₒ-left-monotonicity-implies-EM
  : ((α β : Ordinal 𝓤)(γ : Ordinal 𝓥) → α ⊴ β → (α ×ₒ γ) ⊴ (β ×ₒ γ))
  → EM 𝓤
×ₒ-left-monotonicity-implies-EM hyp P isprop-P = III (f (⋆ , inr ⋆)) refl
 where
  α = 𝟙ₒ
  β = 𝟙ₒ +ₒ prop-ordinal P isprop-P
  γ = 𝟚ₒ

  I : α ⊴ β
  I = ≼-gives-⊴ α β (transport (_≼ β)
                               (𝟘ₒ-right-neutral 𝟙ₒ)
                               (+ₒ-right-monotone 𝟙ₒ 𝟘ₒ (prop-ordinal P isprop-P)
                                 (𝟘ₒ-least _)))

  II : (α ×ₒ γ) ⊴ (β ×ₒ γ)
  II = hyp α β γ I
  f = pr₁ II
  f-sim = pr₂ II
  f-initial-segment = pr₁ f-sim

  f-preserves-least : f (⋆ , inl ⋆) ＝ (inl ⋆ , inl ⋆)
  f-preserves-least = initial-segments-preserve-least (α ×ₒ γ) (β ×ₒ γ)
                        (⋆ , inl ⋆)
                        (inl ⋆ , inl ⋆)
                        f f-initial-segment
                        (minimal-is-least _ _
                          (×ₒ-minimal α γ ⋆ (inl ⋆)
                            ⋆-least
                            (left-preserves-least 𝟙ₒ 𝟙ₒ ⋆ ⋆-least)))
                        (minimal-is-least _ _
                          (×ₒ-minimal β γ (inl ⋆) (inl ⋆)
                            (left-preserves-least 𝟙ₒ (prop-ordinal P isprop-P)
                                                  ⋆ ⋆-least)
                            (left-preserves-least 𝟙ₒ 𝟙ₒ ⋆ ⋆-least)))
   where
    ⋆-least : is-least (𝟙ₒ {𝓤}) ⋆
    ⋆-least ⋆ ⋆ = 𝟘-elim

  III : (x : ⟨ β ×ₒ γ ⟩) → f (⋆ , inr ⋆) ＝ x → P + ¬ P
  III (inl ⋆ , inl ⋆) r = 𝟘-elim (+disjoint' III₂)
   where
    III₁ = f (⋆ , inr ⋆)   ＝⟨ r ⟩
           (inl ⋆ , inl ⋆) ＝⟨ f-preserves-least ⁻¹ ⟩
           f (⋆ , inl ⋆)   ∎
    III₂ : inr ⋆ ＝ inl ⋆
    III₂ = ap pr₂ (simulations-are-lc _ _ f f-sim III₁)

  III (inl ⋆ , inr ⋆) r = inr (λ p → 𝟘-elim (+disjoint (III₆ p)))
   where
    III₃ : (p : P)
         → Σ x ꞉ ⟨ 𝟙ₒ ×ₒ 𝟚ₒ ⟩ ,
             (x ≺⟨ 𝟙ₒ ×ₒ 𝟚ₒ ⟩ (⋆ , inr ⋆)) × (f x ＝ (inr p , inl ⋆))
    III₃ p = f-initial-segment
               (⋆ , inr ⋆) (inr p , inl ⋆)
               (transport⁻¹ (λ - → (inr p , inl ⋆) ≺⟨ β ×ₒ γ ⟩ - ) r (inl ⋆))
    III₄ : (p : P)
         → Σ x ꞉ ⟨ 𝟙ₒ ×ₒ 𝟚ₒ ⟩ ,
             (x ≺⟨ 𝟙ₒ ×ₒ 𝟚ₒ ⟩ (⋆ , inr ⋆)) × (f x ＝ (inr p , inl ⋆))
         → f (⋆ , inl ⋆) ＝ (inr p , inl ⋆)
    III₄ p ((⋆ , inl ⋆) , l , q) = q
    III₄ p ((⋆ , inr ⋆) , l , q) = 𝟘-elim (irrefl (𝟙ₒ ×ₒ 𝟚ₒ) (⋆ , inr ⋆) l)

    III₅ : (p : P) → (inl ⋆ , inl ⋆) ＝ (inr p , inl ⋆)
    III₅ p = (inl ⋆ , inl ⋆) ＝⟨ f-preserves-least ⁻¹ ⟩
             f (⋆ , inl ⋆)   ＝⟨ III₄ p (III₃ p) ⟩
             (inr p , inl ⋆) ∎

    III₆ : (p : P) → inl ⋆ ＝ inr p
    III₆ p = ap pr₁ (III₅ p)

  III (inr p , c) r = inl p

EM-implies-×ₒ-left-monotonicity : EM (𝓤 ⊔ 𝓥)
  → ((α β : Ordinal 𝓤)(γ : Ordinal 𝓥) → α ⊴ β → (α ×ₒ γ) ⊴ (β ×ₒ γ))
EM-implies-×ₒ-left-monotonicity em α β γ (g , g-sim)
 = ≼-gives-⊴ (α ×ₒ γ) (β ×ₒ γ)
             (EM-implies-order-preserving-gives-≼ em (α ×ₒ γ)
                                                     (β ×ₒ γ)
                                                     (f , f-order-preserving))
  where
   f : ⟨  α ×ₒ γ ⟩ → ⟨ β ×ₒ γ ⟩
   f (a , c) = (g a , c)
   f-order-preserving : is-order-preserving (α ×ₒ γ) (β ×ₒ γ) f
   f-order-preserving (a , c) (a' , c') (inl l) = inl l
   f-order-preserving (a , c) (a' , c) (inr (refl , l))
    = inr (refl , simulations-are-order-preserving α β g g-sim a a' l)

EM-implies-induced-⊴-on-×ₒ : EM 𝓤
                           → (α β γ δ : Ordinal 𝓤)
                           → α ⊴ γ → β ⊴ δ
                           → (α ×ₒ β) ⊴ (γ ×ₒ δ)
EM-implies-induced-⊴-on-×ₒ em α β γ δ 𝕗 𝕘 =
 ⊴-trans (α ×ₒ β) (α ×ₒ δ) (γ ×ₒ δ)
         (×ₒ-right-monotone-⊴ α β δ 𝕘)
         (EM-implies-×ₒ-left-monotonicity em α γ δ 𝕗)
\end{code}

To prove that multiplication is left cancellable, we require the following
technical lemma: if α > 𝟘, then every simulation from α ×ₒ β to α ×ₒ γ + α ↓ a₁
firstly never hits the second summand, and secondly, in the first component, it
decomposes as the identity on the first component and a function β → γ on the
second component, viz. one that is independent of the first component.

\begin{code}

simulation-product-decomposition-generalised
 : (α β γ : Ordinal 𝓤)
   ((a₀ , a₀-least) : 𝟘ₒ ⊲ α)
   (a₁ : ⟨ α ⟩)
   ((f , _) : (α ×ₒ β) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁)))
 → Σ g ꞉ (⟨ β ⟩ → ⟨ γ ⟩) , ((a : ⟨ α ⟩) (b : ⟨ β ⟩) → f (a , b) ＝ inl (a , g b))
simulation-product-decomposition-generalised {𝓤 = 𝓤} α β γ (a₀ , a₀-least) a₁ 𝕗@(f , f-sim) = g , g-satisfies-equation
 where
  P : Ordinal 𝓤 →  (𝓤 ⁺) ̇
  P β = (a₁ : ⟨ α ⟩)(γ : Ordinal 𝓤) → ((f , _) : (α ×ₒ β) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁)))
      → (b : ⟨ β ⟩) → Σ c ꞉ ⟨ γ ⟩ , ((a : ⟨ α ⟩) → f (a , b) ＝ inl (a , c))
  P₀ : Ordinal 𝓤 →  (𝓤 ⁺) ̇
  P₀ β = (a₁ : ⟨ α ⟩)(γ : Ordinal 𝓤) → ((f , _) : (α ×ₒ β) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁)))
       → (b : ⟨ β ⟩) → (x : ⟨ (α ×ₒ γ) +ₒ (α ↓ a₁) ⟩) → f (a₀ , b) ＝ x → Σ c ꞉ ⟨ γ ⟩ , f (a₀ , b) ＝ inl (a₀ , c)
  g' : (β : Ordinal 𝓤) → (ih : (b : ⟨ β ⟩) → P (β ↓ b)) → P₀ β
  g' β ih a₁ γ 𝕗@(f , f-sim) b (inl (a' , c)) e = c , (e ∙ ap (λ - → inl (- , c)) p)
   where
    p : a' ＝ a₀
    p = Extensionality α a' a₀ (λ x l → 𝟘-elim (II x l)) (λ x l → 𝟘-elim (transport⁻¹ ⟨_⟩ a₀-least (x , l)))
     where
      I = (α ×ₒ (β ↓ b)) ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ (β ↓ b)) ⁻¹ ∙ ap ((α ×ₒ (β ↓ b)) +ₒ_) a₀-least ⟩
          ((α ×ₒ (β ↓ b)) +ₒ (α ↓ a₀)) ＝⟨ ×ₒ-↓ α β ⁻¹ ⟩
          (α ×ₒ β) ↓ (a₀ , b) ＝⟨ simulations-preserve-↓ _ _ 𝕗 (a₀ , b) ⟩
          ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ f (a₀ , b) ＝⟨ ap (((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓_) e  ⟩
          ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ inl (a' , c) ＝⟨ +ₒ-↓-left (a' , c) ⁻¹ ⟩
          ((α ×ₒ γ) ↓ (a' , c)) ＝⟨ ×ₒ-↓ α γ ⟩
          ((α ×ₒ (γ ↓ c)) +ₒ (α ↓ a')) ∎
      II : (x : ⟨ α ⟩) → ¬ (x ≺⟨ α ⟩ a')
      II x l = +disjoint III
       where
        f' : (α ×ₒ (β ↓ b)) ⊴ ((α ×ₒ (γ ↓ c)) +ₒ (α ↓ a'))
        f' = ≃ₒ-to-⊴ _ _ (idtoeqₒ _ _ I)

        f'⁻¹ : ((α ×ₒ (γ ↓ c)) +ₒ (α ↓ a')) ⊴ (α ×ₒ (β ↓ b))
        f'⁻¹ = ≃ₒ-to-⊴ _ _ (idtoeqₒ _ _ (I ⁻¹))

        equiv : (α β : Ordinal 𝓤) → (eq : α ＝ β) (x : ⟨ β ⟩)
              → [ α , β ]⟨ ≃ₒ-to-⊴ α β (idtoeqₒ α β eq) ⟩ ([ β , α ]⟨ ≃ₒ-to-⊴ β α (idtoeqₒ β α (eq ⁻¹)) ⟩ x) ＝ x
        equiv α β refl x = refl

        x' : ⟨ α ×ₒ (β ↓ b) ⟩
        x' = [ _ , _ ]⟨ f'⁻¹ ⟩ (inr (x , l))
        xₐ = pr₁ x'
        x₂ = pr₂ x'

        x'' = pr₁ (ih b a' (γ ↓ c) f' x₂)
        x''-is-left : [ _ , _ ]⟨ f' ⟩ x' ＝ inl (xₐ , x'')
        x''-is-left = pr₂ (ih b a' (γ ↓ c) f' x₂) xₐ
        III = inl (xₐ , x'') ＝⟨ x''-is-left ⁻¹ ⟩
              [ _ , _ ]⟨ f' ⟩ ([ _ , _ ]⟨ f'⁻¹ ⟩ (inr (x , l))) ＝⟨ equiv _ _ I (inr (x , l)) ⟩
              (inr (x , l)) ∎

  g' β _ a₁ γ 𝕗@(f , f-sim) b (inr (x , p)) e = 𝟘-elim ((order-preserving-gives-not-⊲ α (α ↓ a₁) (h , h-order-preserving) (a₁ , refl)))
   where
    I = α ×ₒ (β ↓ b)                         ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ (β ↓ b)) ⁻¹ ∙ ap ((α ×ₒ (β ↓ b)) +ₒ_) a₀-least ⟩
        (α ×ₒ (β ↓ b)) +ₒ (α ↓ a₀)           ＝⟨ ×ₒ-↓ α β ⁻¹ ⟩
        (α ×ₒ β) ↓ (a₀ , b)                  ＝⟨ simulations-preserve-↓ _ _ 𝕗 (a₀ , b) ⟩
        ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ f (a₀ , b)  ＝⟨ ap (((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓_) e ⟩
        ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ inr (x , p) ＝⟨ +ₒ-↓-right (x , p) ⁻¹ ⟩
        (α ×ₒ γ)  +ₒ ((α ↓ a₁) ↓ (x , p))    ＝⟨ ap ((α ×ₒ γ) +ₒ_) (iterated-↓  α a₁ x p) ⟩
        (α ×ₒ γ)  +ₒ (α ↓ x)                 ∎
    I' = ((α ×ₒ γ) +ₒ ((α ↓ x) +ₒ α)) ＝⟨ +ₒ-assoc (α ×ₒ γ) (α ↓ x) α ⁻¹ ⟩
         ((α ×ₒ γ) +ₒ (α ↓ x)) +ₒ α   ＝⟨ ap (_+ₒ α) I ⁻¹ ⟩
         (α ×ₒ (β ↓ b)) +ₒ α            ＝⟨ ×ₒ-successor α (β ↓ b) ⁻¹ ⟩
         α ×ₒ ((β ↓ b) +ₒ 𝟙ₒ)          ∎
    II : ((α ×ₒ γ) +ₒ ((α ↓ x) +ₒ α)) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁))
    II = transport⁻¹ (λ - → - ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁))) I'
                     (⊴-trans (α ×ₒ ((β ↓ b) +ₒ 𝟙ₒ)) (α ×ₒ β) ((α ×ₒ γ) +ₒ (α ↓ a₁))
                              (×ₒ-right-monotone-⊴ α ((β ↓ b) +ₒ 𝟙ₒ) β
                                (upper-bound-of-successors-of-initial-segments β b))
                              𝕗)
    III : ((α ↓ x) +ₒ α) ⊴ (α ↓ a₁)
    III = ≼-gives-⊴ _ _ (+ₒ-left-reflects-≼ (α ×ₒ γ) ((α ↓ x) +ₒ α) (α ↓ a₁) (⊴-gives-≼ _ _ II))
    III₀ = pr₁ III
    III₀-order-preserving : is-order-preserving ((α ↓ x) +ₒ α) (α ↓ a₁) III₀
    III₀-order-preserving = pr₂ (pr₂ III)
    h : ⟨ α ⟩ → ⟨ α ↓ a₁ ⟩
    h a = III₀ (inr a)
    h-order-preserving : is-order-preserving α (α ↓ a₁) h
    h-order-preserving x y l = III₀-order-preserving (inr x) (inr y) l
  g'' : (β : Ordinal 𝓤) → (ih : (b : ⟨ β ⟩) → P (β ↓ b)) →  P β
  g'' β ih a₁ γ 𝕗@(f , f-sim) b = c , c-satisfies-equation
   where
    c = pr₁ (g' β ih a₁ γ 𝕗 b (f (a₀ , b)) refl)
    c-spec : f (a₀ , b) ＝ inl (a₀ , c)
    c-spec = pr₂ (g' β ih a₁ γ 𝕗 b (f (a₀ , b)) refl)
    c-satisfies-equation : (a : ⟨ α ⟩) → f (a , b) ＝ inl (a , c)
    c-satisfies-equation a = ↓-lc ((α ×ₒ γ) +ₒ (α ↓ a₁)) (f (a , b)) (inl (a , c)) II
     where
      I = (α ×ₒ (β ↓ b)) ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ (β ↓ b)) ⁻¹ ∙ ap ((α ×ₒ (β ↓ b)) +ₒ_) a₀-least ⟩
          (α ×ₒ (β ↓ b)) +ₒ (α ↓ a₀) ＝⟨ ×ₒ-↓ α β ⁻¹ ⟩
          (α ×ₒ β) ↓ (a₀ , b) ＝⟨ simulations-preserve-↓ _ _ 𝕗 (a₀ , b) ⟩
          ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ f (a₀ , b) ＝⟨ ap (((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓_) c-spec ⟩
          ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ inl (a₀ , c) ＝⟨ +ₒ-↓-left (a₀ , c) ⁻¹ ⟩
          ((α ×ₒ γ) ↓ (a₀ , c)) ＝⟨ ×ₒ-↓ α γ ⟩
          (α ×ₒ (γ ↓ c)) +ₒ (α ↓ a₀) ＝⟨ ap ((α ×ₒ (γ ↓ c)) +ₒ_) a₀-least ⁻¹ ∙ 𝟘ₒ-right-neutral (α ×ₒ (γ ↓ c)) ⟩
          (α ×ₒ (γ ↓ c)) ∎

      II = ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ f (a , b) ＝⟨ simulations-preserve-↓ _ _ 𝕗 (a , b) ⁻¹ ⟩
           (α ×ₒ β) ↓ (a , b) ＝⟨ ×ₒ-↓ α β ⟩
           (α ×ₒ (β ↓ b)) +ₒ (α ↓ a) ＝⟨ ap (_+ₒ (α ↓ a)) I ⟩
           ((α ×ₒ (γ ↓ c)) +ₒ (α ↓ a)) ＝⟨ ×ₒ-↓ α γ ⁻¹ ⟩
           ((α ×ₒ γ) ↓ (a , c)) ＝⟨ +ₒ-↓-left (a , c) ⟩
           ((α ×ₒ γ) +ₒ (α ↓ a₁)) ↓ inl (a , c) ∎
  g''' : (b : ⟨ β ⟩) → Σ c ꞉ ⟨ γ ⟩ , ((a : ⟨ α ⟩) → f (a , b) ＝ inl (a , c))
  g''' b = transfinite-induction-on-OO P g'' β a₁ γ 𝕗 b
  g : ⟨ β ⟩ → ⟨ γ ⟩
  g b = pr₁ (g''' b)
  g-satisfies-equation : (a : ⟨ α ⟩)(b : ⟨ β ⟩) → f (a , b) ＝ inl (a , g b)
  g-satisfies-equation a b = pr₂ (g''' b) a

×ₒ-left-cancellable-⊴-generalised : (α β γ : Ordinal 𝓤)(a₁ : ⟨ α ⟩)
                      → 𝟘ₒ ⊲ α
                      → (α ×ₒ β) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a₁))
                      → β ⊴ γ
×ₒ-left-cancellable-⊴-generalised α β γ a₁ p@(a₀ , a₀-least) 𝕗@(f , f-initial , f-order-pres) =
 (g , g-is-initial-segment , g-is-order-preserving)
 where
  g : ⟨ β ⟩ → ⟨ γ ⟩
  g = pr₁ (simulation-product-decomposition-generalised α β γ p a₁ 𝕗)

  g-property :  (a : ⟨ α ⟩)(b : ⟨ β ⟩) → f (a , b) ＝ inl (a , g b)
  g-property = pr₂ (simulation-product-decomposition-generalised α β γ p a₁ 𝕗)

  g-is-initial-segment : is-initial-segment β γ g
  g-is-initial-segment b c l = b' , k' k , e'
   where
    l' : inl (a₀ , c) ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁)) ⟩ inl (a₀ , g b)
    l' = inl l
    l'' : inl (a₀ , c) ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁)) ⟩ f (a₀ , b)
    l'' = transport⁻¹ (λ - → inl (a₀ , c) ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁))⟩ -) (g-property a₀ b) l'
    x : Σ y ꞉ ⟨ α ×ₒ β ⟩ , (y ≺⟨ α ×ₒ β ⟩ (a₀ , b)) × (f y ＝ (inl (a₀ , c)))
    x = f-initial (a₀ , b) (inl (a₀ , c)) l''
    a' = pr₁ (pr₁ x)
    b' = pr₂ (pr₁ x)
    k = pr₁ (pr₂ x)
    e = pr₂ (pr₂ x)

    k' : (a' , b') ≺⟨ α ×ₒ β ⟩ (a₀ , b) → b' ≺⟨ β ⟩ b
    k' (inl p) = p
    k' (inr (r , q)) = 𝟘-elim (transport⁻¹ ⟨_⟩ a₀-least (a' , q))

    e' : g b' ＝ c
    e' = ap pr₂ (inl-lc (g-property a' b' ⁻¹ ∙ e))

  g-is-order-preserving : is-order-preserving β γ g
  g-is-order-preserving b b' l = l''' l''
   where
    l' : f (a₀ , b) ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁)) ⟩ f (a₀ , b')
    l' = f-order-pres (a₀ , b) (a₀ , b') (inl l)
    l'' : inl (a₀ , g b) ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁)) ⟩ inl (a₀ , g b')
    l'' = transport₂ (λ x y → x ≺⟨ ((α ×ₒ γ) +ₒ (α ↓ a₁))⟩ y)
                     (g-property a₀ b)
                     (g-property a₀ b')
                     l'
    l''' : (a₀ , g b) ≺⟨ (α ×ₒ γ) ⟩ (a₀ , g b') → g b ≺⟨ γ ⟩ g b'
    l''' (inl p) = p
    l''' (inr (r , q)) = 𝟘-elim (irrefl α a₀ q)

×ₒ-left-cancellable-⊴ : (α β γ : Ordinal 𝓤)
                      → 𝟘ₒ ⊲ α
                      → (α ×ₒ β) ⊴ (α ×ₒ γ)
                      → β ⊴ γ
×ₒ-left-cancellable-⊴ α β γ p@(a₀ , a₀-least) 𝕗@(f , f-sim) =
  ×ₒ-left-cancellable-⊴-generalised α β γ a₀ p
                                    (transport (λ - → (α ×ₒ β) ⊴ -)
                                               (𝟘ₒ-right-neutral (α ×ₒ γ) ⁻¹ ∙ ap ((α ×ₒ γ) +ₒ_) a₀-least) 𝕗)

{-
simulation-product-decomposition
 : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
   ((a₀ , a₀-least) : 𝟘ₒ ⊲ α)
   ((f , _) : (α ×ₒ β) ⊴ (α ×ₒ γ))
 → (a : ⟨ α ⟩) (b : ⟨ β ⟩) → f (a , b) ＝ (a , pr₂ (f (a₀ , b)))
simulation-product-decomposition {𝓤} {𝓥} α β γ (a₀ , a₀-least)
                                 (f , sim@(init-seg , order-pres)) a b = I
 where
  f' : ⟨ α ×ₒ β ⟩ → ⟨ α ×ₒ γ ⟩
  f' (a , b) = (a , pr₂ (f (a₀ , b)))

  P : ⟨ α ×ₒ β ⟩ → 𝓤 ⊔ 𝓥 ̇
  P (a , b) = (f (a , b)) ＝ f' (a , b)

  I : P (a , b)
  I = Transfinite-induction (α ×ₒ β) P II (a , b)
   where
    II : (x : ⟨ α ×ₒ β ⟩)
       → ((y : ⟨ α ×ₒ β ⟩) → y ≺⟨ α ×ₒ β ⟩ x → P y)
       → P x
    II (a , b) IH = Extensionality (α ×ₒ γ) (f (a , b)) (f' (a , b)) III IV
     where
      III : (u : ⟨ α ×ₒ γ ⟩) → u ≺⟨ α ×ₒ γ ⟩ f (a , b) → u ≺⟨ α ×ₒ γ ⟩ f' (a , b)
      III (a' , c') p = transport (λ - → - ≺⟨ α ×ₒ γ ⟩ f' (a , b)) III₂ (III₃ p')
       where
        III₁ : Σ (a'' , b') ꞉ ⟨ α ×ₒ β ⟩ , (a'' , b') ≺⟨ α ×ₒ β ⟩ (a , b)
                                         × (f (a'' , b') ＝ a' , c')
        III₁ = init-seg (a , b) (a' , c') p
        a'' = pr₁ (pr₁ III₁)
        b' = pr₂ (pr₁ III₁)
        p' = pr₁ (pr₂ III₁)
        eq : f (a'' , b') ＝ (a' , c')
        eq = pr₂ (pr₂ III₁)

        III₂ : f' (a'' , b') ＝ (a' , c')
        III₂ = IH (a'' , b') p' ⁻¹ ∙ eq

        III₃ : (a'' , b') ≺⟨ α ×ₒ β ⟩ (a , b)
             → f' (a'' , b') ≺⟨ α ×ₒ γ ⟩ f' (a , b)
        III₃ (inl q) = h (order-pres (a₀' , b') (a₀ , b) (inl q))
         where
          a₀' : ⟨ α ⟩
          a₀' = pr₁ (f (a₀ , b))

          ih : (f (a₀' , b')) ＝ f' (a₀' , b')
          ih = IH (a₀' , b') (inl q)

          h : f  (a₀' , b') ≺⟨ α ×ₒ γ ⟩ f  (a₀ , b)
            → f' (a'' , b') ≺⟨ α ×ₒ γ ⟩ f' (a , b)
          h (inl r) = inl (transport (λ - → - ≺⟨ γ ⟩ pr₂ (f (a₀ , b)))
                                     (ap pr₂ ih) r)
          h (inr (_ , r)) = 𝟘-elim (irrefl α a₀' (transport (λ - → - ≺⟨ α ⟩ a₀')
                                                            (ap pr₁ ih) r))
        III₃ (inr (e , q)) = inr (ap (λ - → pr₂ (f (a₀ , -))) e , q)

      IV : (u : ⟨ α ×ₒ γ ⟩) → u ≺⟨ α ×ₒ γ ⟩ f' (a , b) → u ≺⟨ α ×ₒ γ ⟩ f  (a , b)
      IV (a' , c') (inl p) = l₂ (a' , c') (inl p)
       where
        l₁ : a₀ ≼⟨ α ⟩ a
        l₁ x p = 𝟘-elim (transport ⟨_⟩ (a₀-least ⁻¹) (x , p))
        l₂ : f (a₀ , b) ≼⟨ α ×ₒ γ ⟩ f (a , b)
        l₂ = simulations-are-monotone _ _
              f sim (a₀ , b) (a , b) (×ₒ-≼-left α β l₁)
      IV (a' , c') (inr (r , q)) =
       transport (λ - → - ≺⟨ α ×ₒ γ ⟩ f  (a , b)) eq
                 (order-pres (a' , b) (a , b) (inr (refl , q)))
        where
         eq = f  (a' , b)             ＝⟨ IH (a' , b) (inr (refl , q)) ⟩
              f' (a' , b)             ＝⟨ refl ⟩
              (a' , pr₂ (f (a₀ , b))) ＝⟨ ap (a' ,_) (r ⁻¹) ⟩
              (a' , c')               ∎
-}
\end{code}

The following result states that multiplication for ordinals can be cancelled on
the left. Interestingly, Andrew Swan [Swa18] proved that the corresponding
result for sets is not provable constructively already for α = 𝟚: there are
toposes where the statement

  𝟚 × X ≃ 𝟚 × Y → X ≃ Y

is not true for certain objects X and Y in the topos.

[Swa18] Andrew Swan
        On Dividing by Two in Constructive Mathematics
        2018
        https://arxiv.org/abs/1804.04490

\begin{code}

×ₒ-left-cancellable : (α β γ : Ordinal 𝓤)
                    → 𝟘ₒ ⊲ α
                    → (α ×ₒ β) ＝ (α ×ₒ γ)
                    → β ＝ γ
×ₒ-left-cancellable {𝓤 = 𝓤} α β γ p e = ⊴-antisym β γ (f β γ e) (f γ β (e ⁻¹))
 where
  f : (β γ : Ordinal 𝓤) → (α ×ₒ β) ＝ (α ×ₒ γ) → β ⊴ γ
  f β γ e = ×ₒ-left-cancellable-⊴ α β γ p (≃ₒ-to-⊴
                                            (α ×ₒ β)
                                            (α ×ₒ γ)
                                            (idtoeqₒ
                                              (α ×ₒ β)
                                              (α ×ₒ γ)
                                              e))

{-
×ₒ-left-cancellable : (α β γ : Ordinal 𝓤)
                    → 𝟘ₒ ⊲ α
                    → (α ×ₒ β) ＝ (α ×ₒ γ)
                    → β ＝ γ
×ₒ-left-cancellable {𝓤} α β γ (a₀ , a₀-least) =
 transfinite-induction-on-OO P II β γ
  where
   P : Ordinal 𝓤 → 𝓤 ⁺ ̇
   P β = (γ : Ordinal 𝓤) → (α ×ₒ β) ＝ (α ×ₒ γ) → β ＝ γ

   I : (β γ : Ordinal 𝓤)
     → (α ×ₒ β) ＝ (α ×ₒ γ)
     → (b : ⟨ β ⟩) → Σ c ꞉ ⟨ γ ⟩ , (α ×ₒ (β ↓ b) ＝ α ×ₒ (γ ↓ c))
   I β γ e b = c , eq
    where
     𝕗 : (α ×ₒ β) ⊴ (α ×ₒ γ)
     𝕗 = ≃ₒ-to-⊴ (α ×ₒ β) (α ×ₒ γ) (idtoeqₒ _ _ e)
     f : ⟨ α ×ₒ β ⟩ → ⟨ α ×ₒ γ ⟩
     f = [ α ×ₒ β , α ×ₒ γ ]⟨ 𝕗 ⟩

     c : ⟨ γ ⟩
     c = pr₂ (f (a₀ , b))

     eq = α ×ₒ (β ↓ b)                ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ (β ↓ b)) ⁻¹ ⟩
          (α ×ₒ (β ↓ b)) +ₒ 𝟘ₒ        ＝⟨ ap ((α ×ₒ (β ↓ b)) +ₒ_) a₀-least ⟩
          (α ×ₒ (β ↓ b)) +ₒ (α ↓ a₀)  ＝⟨ ×ₒ-↓ α β ⁻¹ ⟩
          (α ×ₒ β) ↓ (a₀ , b)         ＝⟨ eq₁ ⟩
          (α ×ₒ γ) ↓ (a₀' , c)        ＝⟨ eq₂ ⟩
          (α ×ₒ γ) ↓ (a₀ , c)         ＝⟨ ×ₒ-↓ α γ ⟩
          (α ×ₒ (γ ↓ c)) +ₒ (α ↓ a₀)  ＝⟨ ap ((α ×ₒ (γ ↓ c)) +ₒ_) (a₀-least ⁻¹) ⟩
          (α ×ₒ (γ ↓ c)) +ₒ 𝟘ₒ        ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ (γ ↓ c)) ⟩
          α ×ₒ (γ ↓ c)                ∎
      where
       a₀' : ⟨ α ⟩
       a₀' = pr₁ (f (a₀ , b))

       eq₁ = simulations-preserve-↓ (α ×ₒ β) (α ×ₒ γ) 𝕗 (a₀ , b)
       eq₂ = ap ((α ×ₒ γ) ↓_)
                (simulation-product-decomposition α β γ (a₀ , a₀-least) 𝕗 a₀ b)

   II : (β : Ordinal 𝓤) → ((b : ⟨ β ⟩) → P (β ↓ b)) → P β
   II β IH γ e = Extensionality (OO 𝓤) β γ (to-≼ III) (to-≼ IV)
    where
     III : (b : ⟨ β ⟩) → (β ↓ b) ⊲ γ
     III b = let (c , eq) = I β γ  e     b in (c , IH b (γ ↓ c) eq)
     IV  : (c : ⟨ γ ⟩) → (γ ↓ c) ⊲ β
     IV  c = let (b , eq) = I γ β (e ⁻¹) c in (b , (IH b (γ ↓ c) (eq ⁻¹) ⁻¹))
-}
\end{code}

Using similar techniques, we can also prove that multiplication is
left cancellable with respect to ⊲.

\begin{code}

simulation-product-decomposition-leftover-empty
 : (α β γ : Ordinal 𝓤)
 → 𝟘ₒ ⊲ α
 → (a : ⟨ α ⟩)
 → (α ×ₒ β) ＝ ((α ×ₒ γ) +ₒ (α ↓ a))
 → (α ×ₒ β) ＝ (α ×ₒ γ)
simulation-product-decomposition-leftover-empty α β γ (a₀ , p) a e = eq
 where
  a-least : (x : ⟨ α ⟩) → ¬ (x ≺⟨ α ⟩ a)
  a-least x l = +disjoint (inr-is-inl ⁻¹)
   where
    𝕗 : (α ×ₒ β) ⊴ ((α ×ₒ γ) +ₒ (α ↓ a))
    𝕗 = ≃ₒ-to-⊴ _ _ (idtoeqₒ _ _ e)
    f = pr₁ 𝕗

    𝕗⁻¹ : ((α ×ₒ γ) +ₒ (α ↓ a)) ⊴ (α ×ₒ β)
    𝕗⁻¹ = ≃ₒ-to-⊴ _ _ (idtoeqₒ _ _ (e ⁻¹))
    f⁻¹ = pr₁ 𝕗⁻¹

    f-decomposition : Σ g ꞉ (⟨ β ⟩ → ⟨ γ ⟩) ,
                        ((a : ⟨ α ⟩)(b : ⟨ β ⟩) → f (a , b) ＝ inl (a , g b) )
    f-decomposition =
      simulation-product-decomposition-generalised α β γ (a₀ , p) a 𝕗
    g = pr₁ f-decomposition

    inr-is-inl = (inr (x , l)) ＝⟨ equiv _ _ e (inr (x , l)) ⟩
                 f (f⁻¹ (inr (x , l))) ＝⟨ pr₂ f-decomposition _ _ ⟩
                 inl (pr₁ (f⁻¹ (inr (x , l))) , g (pr₂ (f⁻¹ (inr (x , l))))) ∎
     where
      equiv : (α β : Ordinal 𝓤) → (eq : α ＝ β) (x : ⟨ β ⟩)
            → x ＝ [ α , β ]⟨ ≃ₒ-to-⊴ α β (idtoeqₒ α β eq) ⟩
                     ([ β , α ]⟨ ≃ₒ-to-⊴ β α (idtoeqₒ β α (eq ⁻¹)) ⟩ x)
      equiv α β refl x = refl


  a-is-a₀ : a ＝ a₀
  a-is-a₀ = Extensionality α a a₀ (λ x l → 𝟘-elim (a-least x l))
                                  (λ x l → 𝟘-elim (transport⁻¹ ⟨_⟩ p (x , l)))

  leftover-empty =
       (α ↓ a) ＝⟨ ap (α ↓_) a-is-a₀ ⟩
       (α ↓ a₀) ＝⟨ p ⁻¹ ⟩
       𝟘ₒ ∎

  eq = (α ×ₒ β) ＝⟨ e ⟩
       (α ×ₒ γ) +ₒ (α ↓ a) ＝⟨ ap ((α ×ₒ γ) +ₒ_) leftover-empty ⟩
       (α ×ₒ γ) +ₒ 𝟘ₒ ＝⟨ 𝟘ₒ-right-neutral (α ×ₒ γ) ⟩
       (α ×ₒ γ) ∎

×ₒ-left-cancellable-⊲ : (α β γ : Ordinal 𝓤)
                      → 𝟘ₒ ⊲ α
                      → (α ×ₒ β) ⊲ (α ×ₒ γ)
                      → β ⊲ γ
×ₒ-left-cancellable-⊲ α β γ α-positive ((a , c) , p) = c , III
 where
  I : (α ×ₒ β) ＝ (α ×ₒ (γ ↓ c)) +ₒ (α ↓ a)
  I = p ∙ ×ₒ-↓ α γ

  II : (α ×ₒ β) ＝ (α ×ₒ (γ ↓ c))
  II = simulation-product-decomposition-leftover-empty α β (γ ↓ c) α-positive a I

  III : β ＝ (γ ↓ c)
  III = ×ₒ-left-cancellable α β (γ ↓ c) α-positive II

\end{code}
