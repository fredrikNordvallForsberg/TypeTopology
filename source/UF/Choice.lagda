Martin Escardo 7 May 2014, 10 Oct 2014, 25 January 2018.

We first look at choice as in the HoTT book a little bit more
abstractly, where for the HoTT book we take T X = ∥ X ∥. It also makes
sense to consider T=¬¬, in connection with the double-negation shift.

Choice in the HoTT book, under the assumption that X is a set and A is
an X-indexed family of sets is

    (Π x ꞉ X , ∥ A x ∥) → ∥ Π x ꞉ X , A x ∥

(a set-indexed product of inhabited sets is inhabited).

We show that, under the same assumptions, this is equivalent

    ∥ (Π x ꞉ X , ∥ A x ∥ → A x) ∥.

Notice that, as shown in the HoTT book, the statement

    (B : 𝓤 ̇ ) → ∥ B ∥ → B

is in contradiction with the univalence axiom (we cannot reveal
secrets in general). However, univalent choice is consistent with the
univalent axiom, and, moreover, gives that

   ∥(B : 𝓤 ̇ ) → ∥ ∥ B ∥ → B ∥

(one can secretly reveal secrets always), which is equivalent to
choice where X is a proposition (see https://arxiv.org/abs/1610.03346).

\begin{code}

{-# OPTIONS --without-K --exact-split --safe --auto-inline #-}

open import MLTT.Spartan
open import UF.Base
open import UF.Equiv
open import UF.FunExt
open import UF.LeftCancellable
open import UF.PropTrunc
open import UF.Subsingletons renaming (⊤Ω to ⊤ ; ⊥Ω to ⊥)
open import UF.Subsingletons-FunExt

module UF.Choice where

module Shift
        (T : {𝓤 : Universe} → 𝓤 ̇ → 𝓤 ̇ )
        (T-functor : {𝓤 𝓥 : Universe} {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → (X → Y) → T X → T Y)
       where

\end{code}

The T-shift for a family A : X → 𝓤 ̇ is

    (Π x ꞉ X , T (A x)) →  T (Π x ꞉ X , A x).

We observe that this is equivalent to

    T (Π x ꞉ X , T (A x) → A x)

This generalizes the T-condition that the double negation shift is
equivalent to

   ¬¬ (Π x ꞉ X , A x + ¬ (A x))

or

   ¬¬ (Π x ꞉ X , ¬¬ A x → A x)

\begin{code}

 Shift : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 Shift {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ ) → (Π x ꞉ X , T (A x)) → T (Π x ꞉ X , A x)

 Shift' : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 Shift' {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ ) → T (Π x ꞉ X , (T (A x) → A x))

 Shift-gives-Shift' : Shift {𝓤} {𝓤} → Shift' {𝓤} {𝓤}
 Shift-gives-Shift' {𝓤} s X A = s X (λ x → T (A x) → A x) (λ x → F s (A x))
  where
   F : Shift → (X : 𝓤 ̇ ) → T (T X → X)
   F s X = s (T X) (λ _ → X) (λ x → x)

 Shift'-gives-Shift : Shift' {𝓤} {𝓥} → Shift {𝓤} {𝓥}
 Shift'-gives-Shift s' X A φ = T-functor (F φ) (s' X A)
  where
   F : ((x : X) → T (A x)) → ((x : X) → T (A x) → A x) → (x : X) → A x
   F φ ψ x = ψ x (φ x)

\end{code}

We now add the above constraints of the HoTT book for choice, but
abstractly, where T may be ∥_∥ and S may be is-set.

\begin{code}

module TChoice
        (T : {𝓤 : Universe} → 𝓤 ̇ → 𝓤 ̇ )
        (T-functor : {𝓤 𝓥 : Universe} {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → (X → Y) → T X → T Y)
        (S : {𝓤 : Universe} → 𝓤 ̇ → 𝓤 ̇ )
        (S-exponential-ideal : {𝓤 𝓥 : Universe} {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
                             → S Y → S (X → Y))
        (T-is-S : {𝓤 : Universe} {X : 𝓤 ̇ } → S (T X))
       where

 Shift : {𝓤 𝓥 : Universe} (X : 𝓤 ̇ ) → (X → 𝓥 ̇ ) → 𝓤 ⊔ 𝓥 ̇
 Shift X A = ((x : X) → T (A x)) → T (Π x ꞉ X , A x)

 Choice : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 Choice {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ ) → S X → (Π x ꞉ X , S (A x)) → Shift X A

 Choice' : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 Choice' {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ )
                  → S X
                  → (Π x ꞉ X , S (A x))
                  → T (Π x ꞉ X , (T (A x) → A x))

 choice-lemma : Choice → (X : 𝓤 ̇ ) → S X → T (T X → X)
 choice-lemma c X s = c (T X) (λ _ → X) T-is-S  (λ x → s) (λ x → x)

 Choice-gives-Choice' : Choice {𝓤} {𝓤} → Choice' {𝓤} {𝓤}
 Choice-gives-Choice' c X A s t = c X
                                    (λ x → T (A x) → A x)
                                    s
                                    (λ x → S-exponential-ideal (t x))
                                    (λ x → choice-lemma c (A x) (t x))

 Choice'-gives-Choice : Choice' {𝓤} {𝓥} → Choice {𝓤} {𝓥}
 Choice'-gives-Choice c' X A s t φ = T-functor (λ ψ x → ψ x (φ x)) (c' X A s t)

\end{code}

January 2018.

Let's formalize the examples discussed above, which give
characterizations choice as in the HoTT book, which we refer to as
Univalent Choice.

\begin{code}

module Univalent-Choice
        (fe : FunExt)
        (pt : propositional-truncations-exist)
        where

 open PropositionalTruncation pt

 open TChoice
       ∥_∥
       ∥∥-functor
       is-set
       (λ Y-is-set → Π-is-set (fe _ _) (λ _ → Y-is-set))
       (props-are-sets ∥∥-is-prop)

 AC : {𝓤 𝓥 𝓦 : Universe} → (𝓤 ⊔ 𝓥 ⊔ 𝓦) ⁺ ̇
 AC {𝓤} {𝓥} {𝓦} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ ) (P : (x : X) → A x → 𝓦 ̇ )
                  → is-set X
                  → ((x : X) → is-set (A x))
                  → ((x : X) (a : A x) → is-prop (P x a))
                  → ((x : X) → ∃ a ꞉ A x , P x a)
                  → ∃ f ꞉ Π A , ((x : X) → P x (f x))

 AC₁ : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 AC₁ {𝓤} {𝓥} = (X : 𝓤 ̇ ) (Y : X → 𝓥 ̇ )
              → is-set X
              → ((x : X) → is-set (Y x))
              → (Π x ꞉ X , ∥ Y x ∥)
              → ∥(Π x ꞉ X , Y x)∥

 AC₂ : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 AC₂ {𝓤} {𝓥} = (X : 𝓤 ̇ ) (Y : X → 𝓥 ̇ ) → is-set X → ((x : X) → is-set (Y x))
              → ∥(Π x ꞉ X , (∥ Y x ∥ → Y x))∥

 AC-gives-AC₁ : AC {𝓤} {𝓥} {𝓦} → AC₁ {𝓤} {𝓥}
 AC-gives-AC₁ ac X Y isx isy f = h
  where
   g : ∃ f ꞉ Π Y , (X → 𝟙)
   g = ac X Y (λ x a → 𝟙) isx isy (λ x a → 𝟙-is-prop) (λ x → ∥∥-functor (λ z → z , ⋆) (f x))

   h : ∥ Π Y ∥
   h = ∥∥-functor pr₁ g

 AC₁-gives-AC : AC₁ {𝓤} {𝓥} → AC {𝓤} {𝓥} {𝓥}
 AC₁-gives-AC ac₁ X A P s t i f = ∥∥-functor ΠΣ-distr g
  where
   g : ∥(Π x ꞉ X , Σ a ꞉ A x , P x a)∥
   g = ac₁ X
           (λ x → Σ a ꞉ A x , P x a)
           s
           (λ x → subsets-of-sets-are-sets (A x) (P x) (t x) (λ {a} → i x a))
           f

 AC₁-gives-AC₂ : AC₁ {𝓤} {𝓤} → AC₂ {𝓤} {𝓤}
 AC₁-gives-AC₂ = Choice-gives-Choice'

 AC₂-gives-AC₁ : AC₂ {𝓤} {𝓥} → AC₁ {𝓤} {𝓥}
 AC₂-gives-AC₁ = Choice'-gives-Choice

 secretly-revealing-secrets : AC₁ → (B : 𝓤 ̇ ) → is-set B → ∥(∥ B ∥ → B)∥
 secretly-revealing-secrets = choice-lemma

\end{code}

Now, assuming excluded middle, choice is equivalent to the double
negation shift.

\begin{code}

open import UF.ExcludedMiddle

module ChoiceUnderEM₀
        (em : Excluded-Middle)
        (pt : propositional-truncations-exist)
        (fe : FunExt)
       where

 open PropositionalTruncation pt
 open Univalent-Choice fe pt

 DNS : {𝓤 𝓥 : Universe} → (𝓤 ⊔ 𝓥)⁺ ̇
 DNS {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓥 ̇ )
              → is-set X
              → ((x : X) → is-set (A x))
              → (Π x ꞉ X , ¬¬ A x)
              → ¬¬ (Π x ꞉ X , A x)

 DNA : {𝓤 𝓥 : Universe} → 𝓤 ⁺ ̇
 DNA {𝓤} {𝓥} = (X : 𝓤 ̇ ) (A : X → 𝓤 ̇ )
              → is-set X
              → ((x : X) → is-set (A x))
              → ¬¬ (Π x ꞉ X , (¬¬ A x → A x))

 private
  α : {X : 𝓤 ̇ } → ∥ X ∥ → ¬¬ X
  α = inhabited-is-nonempty

  β : {X : 𝓤 ̇ } → ¬¬ X → ∥ X ∥
  β = non-empty-is-inhabited pt em

  γ : {X : 𝓤 ̇ } → is-set (¬¬ X)
  γ = props-are-sets (Π-is-prop (fe _ _) (λ _ → 𝟘-is-prop))

 AC₁-gives-DNS : AC₁ {𝓤} {𝓥} → DNS {𝓤} {𝓥}
 AC₁-gives-DNS ac X A i j f = α (ac X A i j (λ x → β (f x)))

 DNS-gives-AC₁ : DNS {𝓤} {𝓥} → AC₁ {𝓤} {𝓥}
 DNS-gives-AC₁ dns X A isx isa g = β (dns X A isx isa (λ x → α (g x)))

 setei : {𝓤 𝓥 : Universe} → {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → is-set Y → is-set (X → Y)
 setei {𝓤} {𝓥} Y-is-set = Π-is-set (fe _ _) (λ _ → Y-is-set)


 DNS-gives-DNA : DNS {𝓤} {𝓤} → DNA {𝓤} {𝓥}
 DNS-gives-DNA = TChoice.Choice-gives-Choice' ¬¬_ ¬¬-functor is-set setei γ

 DNA-gives-DNS : DNA {𝓤} {𝓥} → DNS {𝓤} {𝓤}
 DNA-gives-DNS = TChoice.Choice'-gives-Choice ¬¬_ ¬¬-functor is-set setei γ

\end{code}

But choice implies excluded middle. Provided we have quotients. In
fact, the quotient 𝟚/P of 𝟚 by the relation R ₀ ₁ = P, for any given
proposition P, suffices. In that case, we conclude that, assuming
function extensionality, AC is equivalent to EM × DNS.

What if we don't (necessarily) have the quotient 𝟚/P for an arbitrary
proposition P?  We get from AC that all sets have decidable
equality. This is because the quotient 𝟚/(a₀＝a₁), for two points a₀
and a₁ of a set X can be constructed as the image of the map a:𝟚→X
with values a ₀ = a₀ and a ₁ = a₁.

\begin{code}

module AC-renders-all-sets-discrete
        (pt : propositional-truncations-exist)
        (fe : FunExt)
       where

 open PropositionalTruncation pt
 open Univalent-Choice fe pt public

 open import TypeTopology.DiscreteAndSeparated
 open import UF.ImageAndSurjection pt
 open import UF.Miscelanea

 decidability-lemma : {X : 𝓤 ̇ } (a : 𝟚 → X)
                    → ((x : X) → (∃ i ꞉ 𝟚 , a i ＝ x) → Σ i ꞉ 𝟚 , a i ＝ x)
                    → decidable (a ₀ ＝ a ₁)
 decidability-lemma a c = claim (𝟚-is-discrete (s(r ₀)) (s(r ₁)))
  where
   r : 𝟚 → image a
   r = corestriction a

   r-splits : (y : image a) → Σ i ꞉ 𝟚 , r i ＝ y
   r-splits (x , t) = f (c x t)
    where
     f : (Σ i ꞉ 𝟚 , a i ＝ x) → Σ i ꞉ 𝟚 , r i ＝ (x , t)
     f (i , p) = i , to-Σ-＝ (p , ∥∥-is-prop _ t)

   s : image a → 𝟚
   s y = pr₁(r-splits y)

   rs : (y : image a) → r(s y) ＝ y
   rs y = pr₂(r-splits y)

   s-lc : left-cancellable s
   s-lc = section-lc s (r , rs)

   a-r : {i j : 𝟚} → a i ＝ a j → r i ＝ r j
   a-r p = to-Σ-＝ (p , ∥∥-is-prop _ _)

   r-a : {i j : 𝟚} → r i ＝ r j → a i ＝ a j
   r-a = ap pr₁

   a-s : {i j : 𝟚} → a i ＝ a j → s(r i) ＝ s(r j)
   a-s p = ap s (a-r p)

   s-a : {i j : 𝟚} → s(r i) ＝ s(r j) → a i ＝ a j
   s-a p = r-a (s-lc p)

   claim : decidable (s(r ₀) ＝ s(r ₁)) → decidable (a ₀ ＝ a ₁)
   claim (inl p) = inl (s-a p)
   claim (inr u) = inr (contrapositive a-s u)

 decidability-lemma₂ : {X : 𝓤 ̇ }
                     → is-set X
                     → (a : 𝟚 → X)
                     → ∥((x : X) → (∃ i ꞉ 𝟚 , a i ＝ x) → Σ i ꞉ 𝟚 , a i ＝ x)∥
                     → decidable (a ₀ ＝ a ₁)
 decidability-lemma₂ is a =
  ∥∥-rec (decidability-of-prop-is-prop (fe _ _) is) (decidability-lemma a)

 ac-renders-all-sets-discrete' : AC {𝓤} {𝓤} {𝓤}
                               → (X : 𝓤 ̇ )
                               → is-set X
                               → (a : 𝟚 → X) → decidable (a ₀ ＝ a ₁)
 ac-renders-all-sets-discrete' {𝓤} ac X i a =
  decidability-lemma₂ i a (ac₂ X A i j)
  where
   A : X → 𝓤 ̇
   A x = Σ i ꞉ 𝟚 , a i ＝ x

   j : (x : X) → is-set (A x)
   j x = subsets-of-sets-are-sets 𝟚 (λ i → a i ＝ x) 𝟚-is-set i

   ac₂ : AC₂ {𝓤} {𝓤}
   ac₂ = AC₁-gives-AC₂ (AC-gives-AC₁ ac)

 ac-renders-all-sets-discrete : AC {𝓤} {𝓤} {𝓤}
                              → (X : 𝓤 ̇ )
                              → is-set X
                              → (a₀ a₁ : X) → decidable (a₀ ＝ a₁)
 ac-renders-all-sets-discrete {𝓤} ac X isx a₀ a₁ =
  ac-renders-all-sets-discrete' {𝓤} ac X isx (𝟚-cases a₀ a₁)

\end{code}

Is there a way to define the quotient 𝟚/P for an arbitrary proposition
P, in the universe 𝓤, using propositional truncation as the only HIT,
and funext, propext? We could allow, more generally, univalence.

If so, then, under these conditions, AC is equivalent to excluded
middle together with the double-negation shift for set-indexed
families of sets.

If we assume choice for 𝓤₁ we get excluded middle at 𝓤₀. This is
because the quotient 𝟚/P, for a proposition P in 𝓤₀, exists in 𝓤₁. In
fact, it is the image of the map 𝟚→Prop that sends ₀ to 𝟙 and ₁ to P,
because (𝟙＝P)＝P.

\begin{code}

module EM-and-choice-functions
        (pt : propositional-truncations-exist)
        (pe : PropExt)
        (fe : FunExt)
       where

 open PropositionalTruncation pt
 open AC-renders-all-sets-discrete pt fe

 AC-gives-EM : AC {𝓤 ⁺} {𝓤 ⁺} {𝓤 ⁺} → EM 𝓤
 AC-gives-EM {𝓤} ac =
  Ω-discrete-gives-EM (fe _ _) (pe _)
   (ac-renders-all-sets-discrete {𝓤 ⁺} ac (Ω 𝓤)
     (Ω-is-set (fe 𝓤 𝓤) (pe 𝓤)))

\end{code}

Added 17th December 2022:

\begin{code}

 Choice : 𝓤ω
 Choice = {𝓤 𝓥 𝓦 : Universe} → AC {𝓤} {𝓥} {𝓦}

 Choice-gives-Excluded-Middle : Choice → Excluded-Middle
 Choice-gives-Excluded-Middle ac {𝓤} = AC-gives-EM {𝓤} (ac {𝓤 ⁺})

 open import UF.Powerset
 open UF.Powerset.inhabited-subsets pt

 Choice-Function : 𝓤 ̇ → 𝓤 ⁺ ̇
 Choice-Function X = ∃ ε ꞉ (𝓟⁺ X → X) , ((𝓐 : 𝓟⁺ X) → ε 𝓐 ∈⁺ 𝓐)

 AC₃ : {𝓤 : Universe} → 𝓤 ⁺ ̇
 AC₃ {𝓤} = (X : 𝓤 ̇ ) → is-set X → Choice-Function X

 AC-gives-AC₃ : {𝓤 : Universe} → AC {𝓤 ⁺} {𝓤} {𝓤} → AC₃ {𝓤}
 AC-gives-AC₃ ac X X-is-set =
  ac (𝓟⁺ X)
     (λ (𝓐 : 𝓟⁺ X) → X)
     (λ ((A , i) : 𝓟⁺ X) (x : X) → x ∈ A)
     (𝓟⁺-is-set' (fe _ _) (pe _))
     (λ (_ : 𝓟⁺ X) → X-is-set)
     (λ (A , i) x → ∈-is-prop A x)
     (λ (A , i) → i)

 Choice₃ : 𝓤ω
 Choice₃ = {𝓤 : Universe} → AC₃ {𝓤}

 Choice-gives-Choice₃ : Choice → Choice₃
 Choice-gives-Choice₃ c {𝓤} = AC-gives-AC₃ {𝓤} (c {𝓤 ⁺} {𝓤} {𝓤})

 Choice-Function⁻ : 𝓤 ̇ → 𝓤 ⁺ ̇
 Choice-Function⁻ X = ∃ ε ꞉ (𝓟 X → X) , ((A : 𝓟 X) → is-inhabited A → ε A ∈ A)

 AC₄ : {𝓤 : Universe} → 𝓤 ⁺ ̇
 AC₄ {𝓤} = (X : 𝓤 ̇ ) → is-set X → ∥ X ∥ → Choice-Function⁻ X

 Choice₄ : 𝓤ω
 Choice₄ = {𝓤 : Universe} → AC₄ {𝓤}

 improve-choice-function : EM 𝓤
                      → {X : 𝓤 ̇ }
                      → Choice-Function X
                      → ∥ X ∥
                      → Choice-Function⁻ X
 improve-choice-function em {X} c s = III
  where
   I : (Σ ε⁺ ꞉ (𝓟⁺ X → X) , (((A , i) : 𝓟⁺ X) → (ε⁺ (A , i) ∈ A)))
     → (Σ ε⁺ ꞉ (𝓟⁺ X → X) , ((A : 𝓟 X) (i : is-inhabited A) → ε⁺ (A , i) ∈ A))
   I = NatΣ (λ (ε⁺ : 𝓟⁺ X → X) ε⁺-behaviour A i → ε⁺-behaviour (A , i))

   II : (Σ ε⁺ ꞉ (𝓟⁺ X → X) , ((A : 𝓟 X) (i : is-inhabited A) → ε⁺ (A , i) ∈ A))
      → X
      → (Σ ε ꞉ (𝓟 X → X) , ((A : 𝓟 X) → is-inhabited A → ε A ∈ A))
   II (ε⁺ , f) x = ε , ε-behaviour

    where
     ε' : (A : 𝓟 X) → decidable (is-inhabited A) → X
     ε' A (inl i) = ε⁺ (A , i)
     ε' A (inr ν) = x

     d : (A : 𝓟 X) → decidable (is-inhabited A)
     d A = em (is-inhabited A) (being-inhabited-is-prop A)

     ε : 𝓟 X → X
     ε A = ε' A (d A)

     ε'-behaviour : (A : 𝓟 X)
                  → is-inhabited A
                  → (δ : decidable (is-inhabited A))
                  →  ε' A δ ∈ A
     ε'-behaviour A _ (inl j) = f A j
     ε'-behaviour A i (inr ν) = 𝟘-elim (ν i)

     ε-behaviour : (A : 𝓟 X) → is-inhabited A → ε A ∈ A
     ε-behaviour A i = ε'-behaviour A i (d A)

   III : Choice-Function⁻ X
   III = ∥∥-rec ∃-is-prop (λ x → ∥∥-rec ∃-is-prop (λ σ → ∣ II (I σ) x ∣) c) s

 Choice-gives-Choice₄ : Choice → Choice₄
 Choice-gives-Choice₄ ac X X-is-set = improve-choice-function
                                       (AC-gives-EM ac)
                                       (AC-gives-AC₃ ac X X-is-set)
\end{code}

End of addition.

The following is probably not going to be useful for anything here:

\begin{code}

module Observation
        (𝓤 : Universe)
        (fe : FunExt)
        where

 open import TypeTopology.DiscreteAndSeparated
 open import UF.Miscelanea

 observation : {X : 𝓤 ̇ } (a : 𝟚 → X)
             → ((x : X) → ¬¬ (Σ i ꞉ 𝟚 , a i ＝ x) → Σ i ꞉ 𝟚 , a i ＝ x)
             → decidable (a ₀ ＝ a ₁)
 observation {X} a c = claim (𝟚-is-discrete (s(r ₀)) (s(r ₁)))
  where
   Y = Σ x ꞉ X , ¬¬ (Σ i ꞉ 𝟚 , a i ＝ x)

   r : 𝟚 → Y
   r i = a i , λ u → u (i , refl)

   r-splits : (y : Y) → Σ i ꞉ 𝟚 , r i ＝ y
   r-splits (x , t) = f (c x t)
    where
     f : (Σ i ꞉ 𝟚 , a i ＝ x) → Σ i ꞉ 𝟚 , r i ＝ (x , t)
     f (i , p) = i , to-Σ-＝ (p , negations-are-props (fe 𝓤 𝓤₀) _ t)

   s : Y → 𝟚
   s y = pr₁(r-splits y)

   rs : (y : Y) → r(s y) ＝ y
   rs y = pr₂(r-splits y)

   s-lc : left-cancellable s
   s-lc = section-lc s (r , rs)

   a-r : {i j : 𝟚} → a i ＝ a j → r i ＝ r j
   a-r p = to-Σ-＝ (p , negations-are-props (fe 𝓤 𝓤₀) _ _)

   r-a : {i j : 𝟚} → r i ＝ r j → a i ＝ a j
   r-a = ap pr₁

   a-s : {i j : 𝟚} → a i ＝ a j → s(r i) ＝ s(r j)
   a-s p = ap s (a-r p)

   s-a : {i j : 𝟚} → s(r i) ＝ s(r j) → a i ＝ a j
   s-a p = r-a (s-lc p)

   claim : decidable (s(r ₀) ＝ s(r ₁)) → decidable (a ₀ ＝ a ₁)
   claim (inl p) = inl (s-a p)
   claim (inr u) = inr (λ p → u (a-s p))

\end{code}
