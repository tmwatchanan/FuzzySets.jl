using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A = TriangularFuzzyNumber(levels; number=0.0, width=0.5)
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
@test round(centroid(A, step=0.01), digits=2) ≈ 0.0

B = TriangularFuzzyNumber(levels, number=5.0, width=0.5)
@test B.levels == levels
@test support(B) == Interval(4.5, 5.5)
@test core(B) == Interval(5.0)
@test height(B) == 1

C = TriangularFuzzyNumber(levels, number=5.0, width=0.5)
@test B == C
@test A != C

D = SingletonFuzzyNumber(levels, number=0)
@test support(D) == Interval(0)
@test D.grades == repeat([Interval(0)], length(levels)) # TODO: check with all(...)

A = TriangularFuzzyNumber(levels, number=1, width=0.5)
FuzzySets.clip!(A, α=0.2)
@test A.grades[1] == A.grades[41]
@test A.grades[2] == A.grades[41]
@test A.grades[40] == A.grades[41]
B = FuzzySets.clip(A, α=0.2)
@test B.grades[1] == B.grades[41]
@test B.grades[2] == B.grades[41]
@test B.grades[40] == B.grades[41]

A = SingletonFuzzyNumber(levels, number=5)
B = TriangularFuzzyNumber(levels, number=5)
@test FuzzySets.isSingleton(A) == true
@test FuzzySets.isSingleton(B) == false

p = 6
w_l = 2
w_r = 2
a = 2
@test FuzzySets.trapezoid(0; p, w_l, w_r, a) == Interval(2, 10)
@test FuzzySets.trapezoid(0.5; p, w_l, w_r, a) == Interval(3, 9)
@test FuzzySets.trapezoid(1.0; p, w_l, w_r, a) == Interval(4, 8)
@test_throws ErrorException FuzzySets.trapezoid(1.5; p, w_l, w_r, a)
A = TrapezoidalFuzzyNumber(levels; number=p, w_l, w_r, a)
@test A.grades[1] == Interval(2, 10)
@test A.grades[101] == Interval(3, 9)
@test A.grades[end] == Interval(4, 8)
@test round(centroid(A, step=0.01), digits=2) ≈ p

μ = 0
σ = 1
A = GaussianFuzzyNumber(levels; μ=μ, σ=σ)
@test A.grades[1] == A.grades[2]
@test A.grades[1].left == -A.grades[1].right
@test A.grades[101].left == -A.grades[101].right
@test A.levels[101] == 0.5
@test A.grades[101] == Interval(-1.1774100225154747, 1.1774100225154747)
@test A.grades[end] == Interval(μ)