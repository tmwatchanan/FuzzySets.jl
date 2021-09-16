using FuzzySets, Test
using Plots

step_size = 0.005
levels = collect(0:step_size:1)

A₁ = FuzzyNumber(levels, number=1)
A₂ = FuzzyNumber(levels, number=2)
B₁ = FuzzyNumber(levels, number=0)
B₂ = FuzzyNumber(levels, number=0)

A⃗ = FuzzyVector([A₁, A₂])
B⃗ = FuzzyVector([B₁, B₂])
fig = draw(A⃗)
fig = draw(B⃗, fig=fig)

@test peak_at(A₁) == 1
@test peak_at(A₂) == 2
@test peak_at(B₁) == 0
@test peak_at(B₂) == 0