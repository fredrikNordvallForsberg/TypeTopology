Tom de Jong, Nicolai Kraus, Fredrik Nordvall Forsberg, Chuangjie Xu,
January 2025

This file follows the definitions, equations, lemmas, propositions, theorems and
remarks of the paper "Ordinal Exponentiation in Homotopy Type Theory".

See also Ordinals.Exponentiation.index.lagda for an overview of the relevant
files.

\begin{code}

{-# OPTIONS --safe --without-K --exact-split #-}

open import UF.Univalence
open import UF.PropTrunc
open import UF.Size

\end{code}

Our global assumptions are univalence, the existence of propositional
truncations and set replacement (equivalently, small set quotients).

Function extensionality can be derived from univalence.

\begin{code}

module Ordinals.Exponentiation.Paper
       (ua : Univalence)
       (pt : propositional-truncations-exist)
       (sr : Set-Replacement pt)
       where

open import MLTT.Spartan
open import Notation.General

open import UF.FunExt
open import UF.UA-FunExt

private
 fe : FunExt
 fe = Univalence-gives-FunExt ua

 fe' : Fun-Ext
 fe' {𝓤} {𝓥} = fe 𝓤 𝓥

open import MLTT.List
open import UF.ClassicalLogic
open import UF.DiscreteAndSeparated
open import UF.ImageAndSurjection pt
open import UF.Subsingletons
open PropositionalTruncation pt

open import Ordinals.AdditionProperties ua
open import Ordinals.Arithmetic fe
open import Ordinals.Equivalence
open import Ordinals.Maps
open import Ordinals.MultiplicationProperties ua
open import Ordinals.Notions
open import Ordinals.OrdinalOfOrdinals ua
open import Ordinals.OrdinalOfOrdinalsSuprema ua
open suprema pt sr
open import Ordinals.Type
open import Ordinals.Underlying

open import Ordinals.Exponentiation.DecreasingList ua
open import Ordinals.Exponentiation.DecreasingListProperties-Concrete ua pt sr
open import Ordinals.Exponentiation.PropertiesViaTransport ua pt sr
open import Ordinals.Exponentiation.RelatingConstructions ua pt sr
open import Ordinals.Exponentiation.Specification ua pt sr
open import Ordinals.Exponentiation.Supremum ua pt sr
open import Ordinals.Exponentiation.Taboos ua pt sr
open import Ordinals.Exponentiation.TrichotomousLeastElement ua

\end{code}

Section III. Ordinals in Homotopy Type Theory

\begin{code}

Lemma-1 : (α β : Ordinal 𝓤) (f : ⟨ α ⟩ → ⟨ β ⟩)
        → (is-simulation α β f → (a : ⟨ α ⟩) → α ↓ a ＝ β ↓ f a)
        × (is-simulation α β f → left-cancellable f × is-order-reflecting α β f)
        × (is-simulation α β f × is-surjection f ↔ is-order-equiv α β f)
Lemma-1 α β f = [1] , [2] , [3]
 where
  [1] : is-simulation α β f → (a : ⟨ α ⟩) → α ↓ a ＝ β ↓ f a
  [1] f-sim a = simulations-preserve-↓ α β (f , f-sim) a

  [2] : is-simulation α β f → left-cancellable f × is-order-reflecting α β f
  [2] f-sim =   simulations-are-lc α β f f-sim
              , simulations-are-order-reflecting α β f f-sim

  [3] : is-simulation α β f × is-surjection f ↔ is-order-equiv α β f
  [3] =   (λ (f-sim , f-surj) →
            order-preserving-reflecting-equivs-are-order-equivs α β f
             (surjective-embeddings-are-equivs f
               (simulations-are-embeddings fe α β f f-sim) f-surj)
             (simulations-are-order-preserving α β f f-sim)
             (simulations-are-order-reflecting α β f f-sim))
        , (λ f-equiv →   order-equivs-are-simulations α β f f-equiv
                       , equivs-are-surjections
                          (order-equivs-are-equivs α β f-equiv))

Eq-1 : (α β : Ordinal 𝓤)
     → ((a : ⟨ α ⟩) → (α +ₒ β) ↓ inl a ＝ α ↓ a)
     × ((b : ⟨ β ⟩) → (α +ₒ β) ↓ inr b ＝ α +ₒ (β ↓ b))
Eq-1 α β = (λ a → (+ₒ-↓-left a) ⁻¹) , (λ b → (+ₒ-↓-right b) ⁻¹)

Eq-2 : (α β : Ordinal 𝓤) (a : ⟨ α ⟩) (b : ⟨ β ⟩)
     → (α ×ₒ β) ↓ (a , b) ＝ α ×ₒ (β ↓ b) +ₒ (α ↓ a)
Eq-2 α β a b = ×ₒ-↓ α β

Eq-3 : (I : 𝓤 ̇  ) (F : I → Ordinal 𝓤) (y : ⟨ sup F ⟩)
     → ∃ i ꞉ I , Σ x ꞉ ⟨ F i ⟩ ,
          (y ＝ [ F i , sup F ]⟨ sup-is-upper-bound F i ⟩ x)
        × (sup F ↓ y ＝ F i ↓ x)
Eq-3 I F y = ∥∥-functor h
              (initial-segment-of-sup-is-initial-segment-of-some-component F y)
 where
  h : (Σ i ꞉ I , Σ x ꞉ ⟨ F i ⟩ , sup F ↓ y ＝ F i ↓ x)
    → Σ i ꞉ I , Σ x ꞉ ⟨ F i ⟩ ,
         (y ＝ [ F i , sup F ]⟨ sup-is-upper-bound F i ⟩ x)
       × (sup F ↓ y ＝ F i ↓ x)
  h (i , x , p) = i , x , q , p
   where
    [i,x] = [ F i , sup F ]⟨ sup-is-upper-bound F i ⟩ x
    q : y ＝ [i,x]
    q = ↓-lc (sup F) y [i,x] (p ∙ (initial-segment-of-sup-at-component F i x) ⁻¹)

Lemma-2 : (α : Ordinal 𝓤)
        → ((β γ : Ordinal 𝓥) → β ⊴ γ → α ×ₒ β ⊴ α ×ₒ γ)
        × ({I : 𝓤 ̇  } (F : I → Ordinal 𝓤) → α ×ₒ sup F ＝ sup (λ i → α ×ₒ F i))
Lemma-2 α = ×ₒ-right-monotone-⊴ α , ×ₒ-preserves-suprema pt sr α

Eq-4 : (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) → 𝓤 ⁺ ̇
Eq-4 = exp-full-specification

Lemma-3 : (α : Ordinal 𝓤) (exp-α : Ordinal 𝓤 → Ordinal 𝓤)
        → exp-specification-zero α exp-α
        → exp-specification-succ α exp-α
        → exp-specification-sup  α exp-α
        → (exp-α 𝟙ₒ ＝ α)
        × (exp-α 𝟚ₒ ＝ α ×ₒ α)
        × ((α ≠ 𝟘ₒ) → is-monotone (OO 𝓤) (OO 𝓤) exp-α)
Lemma-3 α exp-α exp-spec-zero exp-spec-succ exp-spec-sup =
   𝟙ₒ-neutral-exp α exp-α exp-spec-zero exp-spec-succ
 , exp-𝟚ₒ-is-×ₒ α exp-α exp-spec-zero exp-spec-succ
 , (λ α-nonzero → is-monotone-if-continuous exp-α (exp-spec-sup α-nonzero))

Proposition-4
 : (Σ exp ꞉ (Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤) , exp-full-specification exp)
 ↔ EM 𝓤
Proposition-4 =
   (λ (exp , (exp-zero , exp-succ , exp-sup)) →
    exponentiation-defined-everywhere-implies-EM
     exp
     exp-zero
     exp-succ
     (λ α → pr₁ (exp-sup α)))
 , EM-gives-full-exponentiation

\end{code}

Section IV. Abstract Algebraic Exponentiation

\begin{code}

Lemma-5 : (β : Ordinal 𝓤) → β ＝ sup (λ b → (β ↓ b) +ₒ 𝟙ₒ)
Lemma-5 = supremum-of-successors-of-initial-segments pt sr

Definition-6 : Ordinal 𝓤 → Ordinal 𝓤 → Ordinal 𝓤
Definition-6 α β = α ^ₒ β

Proposition-7 : (α β : Ordinal 𝓤)
                (a : ⟨ α ⟩) (b : ⟨ β ⟩) (e : ⟨ α ^ₒ (β ↓ b) ⟩)
              → α ^ₒ β ↓ ×ₒ-to-^ₒ α β {b} (e , a)
                ＝ α ^ₒ (β ↓ b) ×ₒ (α ↓ a) +ₒ (α ^ₒ (β ↓ b) ↓ e)
Proposition-7 α β a b e = ^ₒ-↓-×ₒ-to-^ₒ α β

Proposition-8 : (α β γ : Ordinal 𝓤)
              → (β ⊴ γ → α ^ₒ β ⊴ α ^ₒ γ)
              × (𝟙ₒ ⊲ α → β ⊲ γ → α ^ₒ β ⊲ α ^ₒ γ)
Proposition-8 α β γ =   ^ₒ-monotone-in-exponent α β γ
                      , ^ₒ-order-preserving-in-exponent α β γ

Theorem-9 : (α : Ordinal 𝓤) → 𝟙ₒ ⊴ α
          → exp-specification-zero α (α ^ₒ_)
          × exp-specification-succ α (α ^ₒ_)
          × exp-specification-sup α (α ^ₒ_)
Theorem-9 {𝓤} α α-pos =   ^ₒ-satisfies-zero-specification {𝓤} {𝓤} α
                        , ^ₒ-satisfies-succ-specification {𝓤} {𝓤} α α-pos
                        , ^ₒ-satisfies-sup-specification α

Proposition-10 : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
               → α ^ₒ (β +ₒ γ) ＝ (α ^ₒ β) ×ₒ (α ^ₒ γ)
Proposition-10 = ^ₒ-by-+ₒ

Proposition-11 : (α : Ordinal 𝓤) (β γ : Ordinal 𝓥)
               → α ^ₒ (β ×ₒ γ) ＝ (α ^ₒ β) ^ₒ γ
Proposition-11 = ^ₒ-by-×ₒ

\end{code}

Section V. Decreasing Lists: A Constructive Formulation
           of Sierpiński's Definition

\begin{code}

Definition-12 : (α : Ordinal 𝓤) (β : Ordinal 𝓥) → 𝓤 ⊔ 𝓥 ̇
Definition-12 α β = DecrList₂ α β

Remark-13 : (α : Ordinal 𝓤) (β : Ordinal 𝓥)
            ((l , p) (l' , q) : DecrList₂ α β)
          → l ＝ l'
          → (l , p) ＝ (l' , q)
Remark-13 α β _ _ = to-DecrList₂-＝ α β

Proposition-14₁
 : EM 𝓤
 → ((α : Ordinal 𝓤) (x : ⟨ α ⟩) → is-least α x
    → is-well-order (subtype-order α (λ - → x ≺⟨ α ⟩ -)))
Proposition-14₁ = EM-implies-subtype-of-positive-elements-an-ordinal

Proposition-14₂
 : ((α : Ordinal (𝓤 ⁺⁺)) (x : ⟨ α ⟩) → is-least α x
    → is-well-order (subtype-order α (λ - → x ≺⟨ α ⟩ -)))
 → EM 𝓤
Proposition-14₂ = subtype-of-positive-elements-an-ordinal-implies-EM

Lemma-15 : (α : Ordinal 𝓤)
         → (has-trichotomous-least-element α ↔ is-decomposable-into-one-plus α)
         × (((a₀ , a₀-tri) : has-trichotomous-least-element α)
            → (α ＝ 𝟙ₒ +ₒ α ⁺[ a₀ , a₀-tri ])
            × (⟨ α ⁺[ a₀ , a₀-tri ] ⟩ ＝ (Σ a ꞉ ⟨ α ⟩ , a₀ ≺⟨ α ⟩ a)))
Lemma-15 α =   ( trichotomous-least-to-decomposable α
               , decomposable-to-trichotomous-least α)
             , (λ h →   α ⁺[ h ]-part-of-decomposition
                      , ⁺-is-subtype-of-positive-elements α h)

Definition-16 : (α : Ordinal 𝓤) (β : Ordinal 𝓥)
              → has-trichotomous-least-element α
              → Ordinal (𝓤 ⊔ 𝓥)
Definition-16 α β h = exponentiationᴸ α h β

module _
        (α : Ordinal 𝓤)
        (h : has-trichotomous-least-element α)
       where

 private
  α⁺ = α ⁺[ h ]

  NB[α⁺-eq] : α ＝ 𝟙ₒ +ₒ α⁺
  NB[α⁺-eq] = α ⁺[ h ]-part-of-decomposition

  exp[α,_] : Ordinal 𝓦 → Ordinal (𝓤 ⊔ 𝓦)
  exp[α, γ ] = exponentiationᴸ α h γ

 Proposition-17 : (β : Ordinal 𝓥) → has-trichotomous-least-element exp[α, β ]
 Proposition-17 β = exponentiationᴸ-has-trichotomous-least-element α h β

 Lemma-18₁ : (β : Ordinal 𝓥) (γ : Ordinal 𝓦)
             (f : ⟨ β ⟩ → ⟨ γ ⟩)
           → is-order-preserving β γ f
           → ⟨ exp[α, β ] ⟩ → ⟨ exp[α, γ ] ⟩
 Lemma-18₁ β γ = expᴸ-map α⁺ β γ

 Lemma-18₂ : (β : Ordinal 𝓥) (γ : Ordinal 𝓦)
           → β ⊴ γ → exp[α, β ] ⊴ exp[α, γ ]
 Lemma-18₂ β γ (f , (f-init-seg , f-order-pres)) =
    expᴸ-map α⁺ β γ f f-order-pres
  , expᴸ-map-is-simulation α⁺ β γ f f-order-pres f-init-seg

 module _
         (β : Ordinal 𝓥)
        where

  Eq-6 : (b : ⟨ β ⟩) → exp[α, β ↓ b ] ⊴ exp[α, β ]
  Eq-6 = expᴸ-segment-inclusion-⊴ α⁺ β

  ι = expᴸ-segment-inclusion α⁺ β
  ι-list = expᴸ-segment-inclusion-list α⁺ β

  Eq-7 : (a : ⟨ α ⁺[ h ] ⟩) (b : ⟨ β ⟩)
       → (l : ⟨ exp[α, β ] ⟩)
       → is-decreasing-pr₂ α⁺ β ((a , b) ∷ pr₁ l)
       → ⟨ exponentiationᴸ α h (β ↓ b) ⟩
  Eq-7 a b l δ = expᴸ-tail α⁺ β a b (pr₁ l) δ

  τ = expᴸ-tail α⁺ β

  Eq-7-addendum₁
   : (a : ⟨ α⁺ ⟩) (b : ⟨ β ⟩)
     (l₁ l₂ : List ⟨ α⁺ ×ₒ β ⟩)
     (δ₁ : is-decreasing-pr₂ α⁺ β ((a , b) ∷ l₁))
     (δ₂ : is-decreasing-pr₂ α⁺ β ((a , b) ∷ l₂))
   → l₁ ≺⟨List (α⁺ ×ₒ β) ⟩ l₂
   → τ a b l₁ δ₁ ≺⟨ exp[α, β ↓ b ] ⟩ τ a b l₂ δ₂
  Eq-7-addendum₁ a b l₁ l₂ δ₁ δ₂ = expᴸ-tail-is-order-preserving α⁺ β a b δ₁ δ₂

  Eq-7-addendum₂ : (a : ⟨ α⁺ ⟩) (b : ⟨ β ⟩)
                   (l : List ⟨ α⁺ ×ₒ β ⟩)
                   {δ : is-decreasing-pr₂ α⁺ β ((a , b) ∷ l)}
                   {ε : is-decreasing-pr₂ α⁺ β l}
                 → ι b (τ a b l δ) ＝ (l , ε)
  Eq-7-addendum₂ a b = expᴸ-tail-section-of-expᴸ-segment-inclusion α⁺ β a b

  Eq-7-addendum₃ : (a : ⟨ α⁺ ⟩) (b : ⟨ β ⟩)
                   (l : List ⟨ α⁺ ×ₒ (β ↓ b) ⟩)
                   {δ : is-decreasing-pr₂ α⁺ (β ↓ b) l}
                   {ε : is-decreasing-pr₂ α⁺ β ((a , b) ∷ ι-list b l)}
                 → τ a b (ι-list b l) ε ＝ (l , δ)
  Eq-7-addendum₃ a b l {δ} =
   expᴸ-segment-inclusion-section-of-expᴸ-tail α⁺ β a b l δ

  Proposition-19₁
   : (a : ⟨ α⁺ ⟩) (b : ⟨ β ⟩) (l : List ⟨ α⁺ ×ₒ β ⟩)
     (δ : is-decreasing-pr₂ α⁺ β ((a , b) ∷ l))
   → exp[α, β ] ↓ ((a , b ∷ l) , δ)
     ＝ exp[α, β ↓ b ] ×ₒ (𝟙ₒ +ₒ (α⁺ ↓ a)) +ₒ (exp[α, β ↓ b ] ↓ τ a b l δ)
  Proposition-19₁ = expᴸ-↓-cons α⁺ β

  Proposition-19₂
   : (a : ⟨ α⁺ ⟩) (b : ⟨ β ⟩) (l : ⟨ exp[α, β ↓ b ] ⟩)
   → exp[α, β ] ↓ extended-expᴸ-segment-inclusion α⁺ β b l a
     ＝ exp[α, β ↓ b ] ×ₒ (𝟙ₒ +ₒ (α⁺ ↓ a)) +ₒ (exp[α, β ↓ b ] ↓ l)
  Proposition-19₂ = expᴸ-↓-cons' α⁺ β

 Theorem-20 : exp-specification-zero α (λ - → exp[α, - ])
            × exp-specification-succ α (λ - → exp[α, - ])
            × exp-specification-sup α (λ - → exp[α, - ])
 Theorem-20 =   expᴸ-satisfies-zero-specification {𝓤} {𝓤} α⁺
              , transport⁻¹
                 (λ - → exp-specification-succ - (λ - → exp[α, - ]))
                 NB[α⁺-eq]
                 (expᴸ-satisfies-succ-specification {𝓤} α⁺)
              , transport⁻¹
                 (λ - → exp-specification-sup - (λ - → exp[α, - ]))
                 NB[α⁺-eq]
                 (expᴸ-satisfies-sup-specification {𝓤} α⁺)

 Proposition-21 : (β γ : Ordinal 𝓥)
                → exp[α, β +ₒ γ ] ＝ exp[α, β ] ×ₒ exp[α, γ ]
 Proposition-21 = expᴸ-by-+ₒ α⁺

 has-decidable-equality = is-discrete

 Proposition-22 : (β : Ordinal 𝓥)
                → has-decidable-equality ⟨ α ⟩
                → has-decidable-equality ⟨ β ⟩
                → has-decidable-equality ⟨ exp[α, β ] ⟩
 Proposition-22 β = exponentiationᴸ-preserves-discreteness α β h

private
 tri-least : (α : Ordinal 𝓤)
           → has-least α
           → is-trichotomous α
           → has-trichotomous-least-element α
 tri-least α (⊥ , ⊥-is-least) t =
  ⊥ ,
  is-trichotomous-and-least-implies-is-trichotomous-least α ⊥ (t ⊥) ⊥-is-least

Proposition-23
 : (α : Ordinal 𝓤) (β : Ordinal 𝓥) (h : has-least α)
 → (t : is-trichotomous α)
 → is-trichotomous β
 → is-trichotomous (exponentiationᴸ α (tri-least α h t) β)
Proposition-23 = exponentiationᴸ-preserves-trichotomy

\end{code}

Section VI. Abstract and Concrete Exponentiation

\begin{code}

Theorem-24 : (α β : Ordinal 𝓤) (h : has-trichotomous-least-element α)
           → α ^ₒ β ＝ exponentiationᴸ α h β
Theorem-24 α β h = (exponentiation-constructions-agree α β h) ⁻¹

Corollary-25₁ : (α β : Ordinal 𝓤)
              → has-trichotomous-least-element α
              → is-discrete ⟨ α ⟩
              → is-discrete ⟨ β ⟩
              → is-discrete ⟨ α ^ₒ β ⟩
Corollary-25₁ =
 ^ₒ-preserves-discreteness-for-base-with-trichotomous-least-element

Corollary-25₂ : (α β : Ordinal 𝓤)
              → has-least α
              → is-trichotomous α
              → is-trichotomous β
              → is-trichotomous (α ^ₒ β)
Corollary-25₂ = ^ₒ-preserves-trichotomy

module _
        (α β γ : Ordinal 𝓤)
        (h : has-trichotomous-least-element α)
       where

 private
  h' : has-trichotomous-least-element (exponentiationᴸ α h β)
  h' = exponentiationᴸ-has-trichotomous-least-element α h β

 Corollary-26
  : exponentiationᴸ α h (β ×ₒ γ) ＝ exponentiationᴸ (exponentiationᴸ α h β) h' γ
 Corollary-26 = exponentiationᴸ-by-×ₒ α h β γ

module _
        (α : Ordinal 𝓤)
       where

 open denotations α

 Definition-27 : (β : Ordinal 𝓥) → DecrList₂ α β → ⟨ α ^ₒ β ⟩
 Definition-27 β l = ⟦ l ⟧⟨ β ⟩

 -- Remark-28: By inspection of the definition of denotation.

 Proposition-29 : (β : Ordinal 𝓥) → is-surjection (λ l → ⟦ l ⟧⟨ β ⟩)
 Proposition-29 = ⟦⟧-is-surjection

module _
        (α : Ordinal 𝓤)
        (h : has-trichotomous-least-element α)
        (β : Ordinal 𝓤)
       where

 open denotations

 private
  α⁺ = α ⁺[ h ]

  NB : α ＝ 𝟙ₒ +ₒ α⁺
  NB = α ⁺[ h ]-part-of-decomposition

 con-to-abs : ⟨ expᴸ[𝟙+ α⁺ ] β ⟩ → ⟨ (𝟙ₒ +ₒ α⁺) ^ₒ β ⟩
 con-to-abs = induced-map α⁺ β

 Lemma-31 : con-to-abs ∼ denotation' α⁺ β

 Lemma-32 : denotation (𝟙ₒ +ₒ α⁺) β ∼ denotation' α⁺ β ∘ normalize α⁺ β

 Theorem-30 : denotation (𝟙ₒ +ₒ α⁺) β ∼ con-to-abs ∘ (normalize α⁺ β)
 Theorem-30 l = (Lemma-32 l) ∙ (Lemma-31 (normalize α⁺ β l) ⁻¹)

 Lemma-31 = induced-map-is-denotation' α⁺ β

 Lemma-32 = denotations-are-related-via-normalization α⁺ β

 -- Remark-33: No formalizable content

\end{code}

Section VII. Constructive Taboos

\begin{code}

Proposition-34
 : (((α β γ : Ordinal 𝓤) → 𝟙ₒ{𝓤} ⊴ α → α ⊴ β → α ^ₒ γ ⊴ β ^ₒ γ) ↔ EM 𝓤)
 × (((α β γ : Ordinal 𝓤) → 𝟙ₒ {𝓤} ⊴ α → α ⊲ β → α ^ₒ γ ⊴ β ^ₒ γ) → EM 𝓤)
 × (((α β : Ordinal 𝓤) → 𝟙ₒ {𝓤} ⊴ α → α ⊲ β → α ×ₒ α ⊴ β ×ₒ β) → EM 𝓤)
Proposition-34 =   (  ^ₒ-monotone-in-base-implies-EM
                   , (λ em α β γ _ → EM-implies-exp-monotone-in-base em α β γ))
                 , ^ₒ-weakly-monotone-in-base-implies-EM
                 , ×ₒ-weakly-monotone-in-both-arguments-implies-EM

Lemma-35 : (P : 𝓤 ̇  ) (i : is-prop P)
         → let Pₒ = prop-ordinal P i in
           𝟚ₒ {𝓤} ^ₒ Pₒ ＝ 𝟙ₒ +ₒ Pₒ
Lemma-35 = ^ₒ-𝟚ₒ-by-prop

Proposition-36 : ((α β : Ordinal 𝓤) → 𝟙ₒ{𝓤} ⊲ α → β ⊴ α ^ₒ β) ↔ EM 𝓤
Proposition-36 =   ^ₒ-as-large-as-exponent-implies-EM
                 , EM-implies-^ₒ-as-large-as-exponent

\end{code}