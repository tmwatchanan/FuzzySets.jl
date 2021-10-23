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