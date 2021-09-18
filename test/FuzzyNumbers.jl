using FuzzySets, Test

step_size = 0.005
levels = collect(0:step_size:1)

A = FuzzyNumber(levels, number=0.0, width=0.5)
@test A.levels == levels
@test maximum(maximum(A.grades)) == 0.0
@test A[-0.2] == 0.6
@test A[0] == 1.0
@test A[0.2] == 0.6
@test A[0.5] == 0.0
@test A[1] == 0.0

B = FuzzyNumber(levels, number=5.0, width=0.5)
@test B.levels == levels
@test maximum(maximum(B.grades)) == 5.0

draw(A)

using GLMakie
points = [Point2f0(A.grades[i][1], A.levels[i]) => Point2f0(A.grades[i][2], A.levels[i]) for i = 1:length(A.levels)]
linesegments(points, color = :red, linewidth = 2)
