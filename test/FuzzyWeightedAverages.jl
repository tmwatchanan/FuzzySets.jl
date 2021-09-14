using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

a₁ = 2
a₂ = 5
w₁ = 0.25
w₂ = 0.75
A₁ = FuzzySets.FuzzyNumber(levels, number=a₁)
A₂ = FuzzySets.FuzzyNumber(levels, number=a₂)
W₁ = FuzzySets.FuzzyNumber(levels, number=w₁)
W₂ = FuzzySets.FuzzyNumber(levels, number=w₂)
μ = (w₁*a₁ + w₂*a₂) / (w₁ + w₂)

X⃗ = FuzzySets.FuzzyVector([A₁, A₂])
W⃗ = FuzzySets.FuzzyVector([W₁, W₂])
AVG = FuzzySets.fuzzy_weighted_average(X⃗, W⃗)
@test maximum(maximum(AVG.grades)) == μ

# fv = fv ∪ [A₂]