using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A₁ = FuzzyNumber(levels, number=1)
A₂ = FuzzyNumber(levels, number=2)
B₁ = FuzzyNumber(levels, number=0)
B₂ = FuzzyNumber(levels, number=0)

A⃗ = FuzzyVector([A₁, A₂])
B⃗ = FuzzyVector([B₁])

@test FuzzySets.d_dsw(A⃗, A⃗) == SingletonFuzzyNumber(levels, number=0)
@test FuzzySets.d_dsw(A⃗, B⃗) == false

@test FuzzySets.d_interval(A⃗, A⃗) == SingletonFuzzyNumber(levels, number=0)
@test FuzzySets.d_interval(A⃗, B⃗) == false


A = FuzzyNumber(levels, number=1, width=0.5)
B = FuzzySets.clip(A)
@test B.grades[1] == B.grades[41]
@test B.grades[2] == B.grades[41]
@test B.grades[40] == B.grades[41]


# Test cases from "Analysis and Efficient Implementation of a Linguistic Fuzzy C-Means" by S Auephanwiriyakul and JM Keller
X = [Interval(1, 4), Interval(2, 3)]
u = [Interval(0, 0.4), Interval(0.6, 1)]
m = 2.0
@test round(FuzzySets.km_iwa(X, u, bound="lower", m=m), digits=2) == 1.69
@test round(FuzzySets.km_iwa(X, u, bound="upper", m=m), digits=2) == 3.31
@test_throws ArgumentError FuzzySets.km_iwa(X, u, bound="something", m=2.0)

# Test cases from "Uncertain Rule-Based Fuzzy Systems Introduction and New Directions" by Jerry M. Mendel
X = [Interval(1), Interval(2), Interval(3), Interval(4), Interval(5)]
u = [Interval(0.6, 0.9), Interval(0.5, 0.7), Interval(0.65, 0.8), Interval(0.2, 0.4), Interval(0.3, 0.75)]
m = 1.0
@test round(FuzzySets.km_iwa(X, u, bound="lower", m=m), digits=3) == 2.382
@test round(FuzzySets.km_iwa(X, u, bound="upper", m=m), digits=3) == 3.069


butterfly_patterns = FuzzyVector[
    FuzzyVector([FuzzyNumber(levels, number=-3), FuzzyNumber(levels, number=-2)]),
    FuzzyVector([FuzzyNumber(levels, number=-3), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=-3), FuzzyNumber(levels, number=2)]),
    FuzzyVector([FuzzyNumber(levels, number=-2), FuzzyNumber(levels, number=-1)]),
    FuzzyVector([FuzzyNumber(levels, number=-2), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=-2), FuzzyNumber(levels, number=1)]),
    FuzzyVector([FuzzyNumber(levels, number=-1), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=0), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=1), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=2), FuzzyNumber(levels, number=-1)]),
    FuzzyVector([FuzzyNumber(levels, number=2), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=2), FuzzyNumber(levels, number=1)]),
    FuzzyVector([FuzzyNumber(levels, number=3), FuzzyNumber(levels, number=-2)]),
    FuzzyVector([FuzzyNumber(levels, number=3), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=3), FuzzyNumber(levels, number=2)]),
]
cluster_prototypes = FuzzyVector[
    FuzzyVector([FuzzyNumber(levels, number=-2.1), FuzzyNumber(levels, number=0)]),
    FuzzyVector([FuzzyNumber(levels, number=2.1), FuzzyNumber(levels, number=0)]),
]

m = 2.0

grades = [FuzzySets.u_dsw(FuzzySets.cut(butterfly_patterns[1], α), FuzzySets.cut(cluster_prototypes, α), 1, m=m) for α in levels]
A = FuzzyNumber(levels, grades)
draw(A)
grades = [FuzzySets.u_dsw(FuzzySets.cut(butterfly_patterns[1], α), FuzzySets.cut(cluster_prototypes, α), 2, m=m) for α in levels]
B = FuzzyNumber(levels, grades)
draw(B)

m = 2.0
U = [[0.86, 0.14], [0.97, 0.03], [0.86, 0.14], [0.95, 0.05], [1.00, 0.00], [0.95, 0.05], [0.89, 0.11], [0.50, 0.50], [0.11, 0.89], [0.05, 0.95], [0.00, 1.00], [0.05, 0.95], [0.14, 0.86], [0.03, 0.97], [0.14, 0.86]]
b = FuzzySets.cut(cluster_prototypes, 1)
for i = 1:length(U)
    a = FuzzySets.cut(butterfly_patterns[i], 1)
    @test round(FuzzySets.u_dsw(a, b, 1, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 1, m=m).right, digits=2) == U[i][1]
    @test round(FuzzySets.u_dsw(a, b, 2, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 2, m=m).right, digits=2) == U[i][2]
end

m = 1.25
U = [[1.00, 0.00], [1.00, 0.00], [1.00, 0.00], [1.00, 0.00], [1.00, 0.00], [1.00, 0.00], [1.00, 0.00], [0.50, 0.50], [0.00, 1.00], [0.00, 1.00], [0.00, 1.00], [0.00, 1.00], [0.00, 1.00], [0.00, 1.00], [0.00, 1.00]]
b = FuzzySets.cut(cluster_prototypes, 1)
for i = 1:length(U)
    a = FuzzySets.cut(butterfly_patterns[i], 1)
    @test round(FuzzySets.u_dsw(a, b, 1, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 1, m=m).right, digits=2) == U[i][1]
    @test round(FuzzySets.u_dsw(a, b, 2, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 2, m=m).right, digits=2) == U[i][2]
end

m = 6
U = [[0.59, 0.41], [0.67, 0.33], [0.59, 0.41], [0.64, 0.36], [0.82, 0.18], [0.64, 0.36], [0.60, 0.40], [0.50, 0.50], [0.40, 0.60], [0.36, 0.64], [0.18, 0.82], [0.36, 0.64], [0.41, 0.59], [0.33, 0.67], [0.41, 0.59]]
b = FuzzySets.cut(cluster_prototypes, 1)
for i = 1:2
    for k = 1:length(U)
        a = FuzzySets.cut(butterfly_patterns[k], 1)
        print(round(FuzzySets.u_dsw(a, b, i, m=m).left, digits=2), " ")
    end
    println()
end
for i = 1:length(U)
    a = FuzzySets.cut(butterfly_patterns[i], 1)
    @test round(FuzzySets.u_dsw(a, b, 1, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 1, m=m).right, digits=2) == U[i][1]
    @test round(FuzzySets.u_dsw(a, b, 2, m=m).left, digits=2) == round(FuzzySets.u_dsw(a, b, 2, m=m).right, digits=2) == U[i][2]
end

m = 6
h = 1 / (1 - m)
c1 = [-2.1, 0]
c2 = [2.1, 0]
x = [-3, 0]
term1 = sum((x - c1).^2)^h
term2 = sum((x - c2).^2)^h
denom = term1 + term2
u1_crisp = term1 / denom
u2_crisp = term2 / denom
