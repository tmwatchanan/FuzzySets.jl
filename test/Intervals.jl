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