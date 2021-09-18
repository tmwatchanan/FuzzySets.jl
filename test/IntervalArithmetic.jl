using FuzzySets, Test

a = [2, 4]
b = [3, 5]

@test a + b == [5, 9]
@test a - b == [-3, 1]
@test a * b == [6, 20]
@test a / b == [2/5, 4/3]
