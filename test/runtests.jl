using FuzzySets, Test

@time begin
@time @testset "Fuzzy Sets" begin include("FuzzySets.jl") end
@time @testset "Fuzzy Numbers" begin include("FuzzyNumbers.jl") end
@time @testset "Fuzzy Vectors" begin include("FuzzyVectors.jl") end
@time @testset "Interval Arithmetic" begin include("IntervalArithmetic.jl") end
@time @testset "Fuzzy Weighted Averages" begin include("FuzzyWeightedAverages.jl") end
@time @testset "LFCM" begin include("LFCM.jl") end
end