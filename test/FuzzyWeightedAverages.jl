using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

a₁ = 2
a₂ = 5
w₁ = 0.25
w₂ = 0.75
A₁ = FuzzyNumber(levels, number=a₁)
A₂ = FuzzyNumber(levels, number=a₂)
W₁ = FuzzyNumber(levels, number=w₁)
W₂ = FuzzyNumber(levels, number=w₂)
μ = (w₁*a₁ + w₂*a₂) / (w₁ + w₂)

X⃗ = FuzzyVector([A₁, A₂])
W⃗ = FuzzyVector([W₁, W₂])
AVG = fuzzy_weighted_average(X⃗, W⃗)
@test core(AVG) == Interval(μ)
draw(AVG)

x₁ = Interval(1.8, 2.2)
x₂ = Interval(2.8, 3.2)
w₁ = Interval(0.55, 0.95)
w₂ = Interval(0.05, 0.45)
combinations = FuzzySets.getcombinations([x₁, x₂], [w₁, w₂])
@test combinations == [
    1.8  2.8  0.55  0.05;
    2.2  2.8  0.55  0.05;
    1.8  3.2  0.55  0.05;
    2.2  3.2  0.55  0.05;
    1.8  2.8  0.95  0.05;
    2.2  2.8  0.95  0.05;
    1.8  3.2  0.95  0.05;
    2.2  3.2  0.95  0.05;
    1.8  2.8  0.55  0.45;
    2.2  2.8  0.55  0.45;
    1.8  3.2  0.55  0.45;
    2.2  3.2  0.55  0.45;
    1.8  2.8  0.95  0.45;
    2.2  2.8  0.95  0.45;
    1.8  3.2  0.95  0.45;
    2.2  3.2  0.95  0.45;
]
grades = FuzzySets.fwa(combinations)
@test grades ≈ Interval(1.85, 2.65)