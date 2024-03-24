using FuzzySets, Test

@test FuzzySets.name() == "FuzzySets.jl"

step_size = 0.005
levels = collect(0:step_size:1)

A = TriangularFuzzyNumber(levels, number=0.0, width=0.5)
@test A.levels == levels
@test A.grades[1] == Interval(-0.5, 0.5)
@test A[1] == Interval(-0.5, 0.5)
@test A(-0.2) == 0.6
@test A(0) == 1.0
@test A(0.2) == 0.6
@test A(0.5) == 0.0
@test A(1) == 0.0
@test length(A) == 201

@test support(A) == Interval(-0.5, 0.5)
@test core(A) == Interval(0) == Interval(0.0)
@test height(A) == 1.0
@test cut(A, 0) == Interval(-0.5, 0.5)
@test cut(A, 0.5) == Interval(-0.25, 0.25)
@test cut(A, 1) == Interval(0)
