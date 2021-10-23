using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A₁ = FuzzyNumber(levels, number=1)
A₂ = FuzzyNumber(levels, number=2)
B₁ = FuzzyNumber(levels, number=0)
B₂ = FuzzyNumber(levels, number=0)

A⃗ = FuzzyVector([A₁, A₂])
@test length(A⃗) == 2
@test A⃗[1] == A₁
@test A⃗[2] == A₂
@test iterate(A⃗, 1) == A₁
@test iterate(A⃗, 2) == A₂
@test isnothing(iterate(A⃗, 3))

B⃗ = FuzzyVector([B₁])
@test length(B⃗) == 1
@test B⃗[1] == B₁
B⃗ = B⃗ ∪ [B₂]
@test length(B⃗) == 2
@test B⃗[1] == B₁
@test B⃗[2] == B₂

@test A⃗ == A⃗
@test A⃗ == FuzzyVector([A₁, A₂])
@test B⃗ != FuzzyVector([A₁, A₂])

@test cut(A⃗, 0) == [Interval(0.5, 1.5), Interval(1.5, 2.5)]
@test cut(A⃗, 1) == [Interval(1), Interval(2)]

C₁ = FuzzyNumber(levels, number=-1)
C₂ = FuzzyNumber(levels, number=3)
C⃗ = FuzzyVector([C₁, C₂])

patterns = [A⃗, C⃗]
@test cut(patterns, 1, 1) == [Interval(1), Interval(-1)]
@test cut(patterns, 2, 1) == [Interval(2), Interval(3)]