using FuzzySets, Test

A₁ = FuzzySets.FuzzyNumber(levels, number=1)
A₂ = FuzzySets.FuzzyNumber(levels, number=2)

A⃗ = FuzzySets.FuzzyVector([A₁, A₂])
# FuzzySets.draw(A⃗)

plot(A₁[1],)
