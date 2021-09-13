using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A = FuzzySets.FuzzyNumber(levels, number=0.0)
@test A.levels == levels
# @test maximum(maximum(A.grades)) == 0.0

B = FuzzySets.FuzzyNumber(levels, number=5.0)
@test B.levels == levels
# @test maximum(maximum(B.grades)) == 5.0