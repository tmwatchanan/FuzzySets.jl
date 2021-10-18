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

a = Interval(-0.5, 0.5)
b = Interval(7.5, 8.5)


A = FuzzyNumber(levels, number=1, width=0.5)
B = FuzzySets.clip(A)
@test B.grades[1] == B.grades[41]
@test B.grades[2] == B.grades[41]
@test B.grades[40] == B.grades[41]
