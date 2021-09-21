using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A = FuzzyNumber(levels, number=0.0, width=0.5)
@test A.levels == levels
@test A.grades[1] == Interval(-0.5, 0.5)
@test support(A) == Interval(-0.5, 0.5)
@test core(A) == Interval(0) == Interval(0.0)
@test height(A) == 1.0
@test A(-0.2) == 0.6
@test A(0) == 1.0
@test A(0.2) == 0.6
@test A(0.5) == 0.0
@test A(1) == 0.0

B = FuzzyNumber(levels, number=5.0, width=0.5)
@test B.levels == levels
@test support(B) == Interval(4.5, 5.5)
@test core(B) == Interval(5.0)
@test height(B) == 1

C = FuzzyNumber(levels, number=5.0, width=0.5)
@test B == C
@test A != C

D = SingletonFuzzyNumber(levels, number=0)
@test support(D) == Interval(0)
@test D.grades == repeat([Interval(0)], length(levels)) # TODO: check with all(...)