using FuzzySets, Test

empty = Interval() # empty interval
@test isnan(empty.left)
@test isnan(empty.right)

a = Interval(2, 4)
@test mid(a) == 3
@test rad(a) == 1

b = Interval(3, 5)
@test b == Interval(3, 5)

@test a + b == Interval(5, 9)
@test a - b == Interval(-3, 1)
@test a * b == Interval(6, 20)
@test a / b == Interval(2/5, 4/3)

c = 1 .. 2
@test c * (c - c) == Interval(-2, 2)
@test c * c - c * c == Interval(-3, 3)

a⃗ = [a, b, c]
for (idx, x) in enumerate(zip(a, b))
    if idx == 1
        @test x == (2, 3)
    elseif idx == 2
        @test x == (4, 5)
    end
end

# Fuzzy distances
a = Interval(1.5, 2.5)
b = Interval(1.5, 2.5)
@test a - b == Interval(-1.0, 1.0)
@test (a - b) ^ 2 == Interval(0, 1.0)

a = Interval(0.5, 1.5)
b = Interval(0.6, 1.6)
@test a - b == Interval(-1.1, 0.9)
@test (a - b) ^ 2 ≈ Interval(0, 1.21)

a = Interval(0, 2.21)
b = Interval(0, 1.48)
@test a - b == Interval(-1.48, 2.21)
@test (a - b) ^ 2 == Interval(0, 4.8841)

@test 1 / Interval(0.4, 1.6) == Interval(0.625, 2.5)
@test 1 / Interval(-0.4, 1.6) == Interval(-2.5, 0.625)
@test 1 / Interval(0, 25) == Interval(0, 0.04)
@test 1 / (1 + Interval(0.4, 4)) ≈ Interval(0.2, 0.7142857142857143)

a = Interval(0.3, 0.6)
b = Interval(0.4, 0.7)
@test a - b == Interval(0.3-0.7, 0.6-0.4)
@test (a - b)^2 == Interval(0, max((0.3-0.7)^2, (0.6-0.4)^2))