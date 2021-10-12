using FuzzySets, Test

empty = Interval() # empty interval
@test isnan(empty.left)
@test isnan(empty.right)

a = Interval(2, 4)
@test mid(a) == 3
@test rad(a) == -1

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
@test first(z) == (a[1], b[1])

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