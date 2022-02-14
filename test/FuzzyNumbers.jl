using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A = FuzzyNumber(levels, number=0.0, width=0.5)
@test A.levels == levels
@test A.grades[1] == Interval(-0.5, 0.5)
@test A[1] == Interval(-0.5, 0.5)
@test support(A) == Interval(-0.5, 0.5)
@test core(A) == Interval(0) == Interval(0.0)
@test height(A) == 1.0
@test A(-0.2) == 0.6
@test A(0) == 1.0
@test A(0.2) == 0.6
@test A(0.5) == 0.0
@test A(1) == 0.0
@test length(A) == 201

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

A = FuzzyNumber(levels, number=1, width=0.5)
FuzzySets.clip!(A, 0.2)
B = FuzzySets.clip(A, 0.2)
@test B.grades[1] == B.grades[41]
@test B.grades[2] == B.grades[41]
@test B.grades[40] == B.grades[41]

A = FuzzyNumber(levels, number=0, width=2)
draw(A)
B = FuzzySets.clip(A, left=-1, right=1)
draw(B)
@test B.grades[1] == Interval(-1, 1)
@test B.grades[2] == B.grades[41]
@test B.grades[40] == B.grades[41]

A = SingletonFuzzyNumber(levels, number=5)
B = FuzzyNumber(levels, number=5)
@test FuzzySets.isSingleton(A) == true
@test FuzzySets.isSingleton(B) == false