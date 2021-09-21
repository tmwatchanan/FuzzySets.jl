using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A₁ = FuzzyNumber(levels, number=1)
A₂ = FuzzyNumber(levels, number=2)
B₁ = FuzzyNumber(levels, number=0)
B₂ = FuzzyNumber(levels, number=0)

A⃗ = FuzzyVector([A₁, A₂])
B⃗ = FuzzyVector([B₁])

@test FuzzySets.d(A⃗, A⃗) == FuzzyNumber(levels, number=0)
@test FuzzySets.d(A⃗, B⃗) == false