using FuzzySets, Test

@time begin
@time @testset "Fuzzy Sets" begin include("FuzzySets.jl") end
@time @testset "Fuzzy Numbers" begin include("FuzzyNumbers.jl") end
@time @testset "Fuzzy Vectors" begin include("FuzzyVectors.jl") end
@time @testset "Intervals" begin include("Intervals.jl") end
@time @testset "Fuzzy Weighted Averages" begin include("FuzzyWeightedAverages.jl") end
@time @testset "IT2-FCM" begin include("IT2FCM.jl") end
@time @testset "LFCM" begin include("LFCM.jl") end
@time @testset "Utilities" begin include("Utilities.jl") end
end