using FuzzySets, Test

@time begin
@time @testset "Fuzzy Sets" begin include("FuzzySets.jl") end
@time @testset "Fuzzy Numbers" begin include("FuzzyNumbers.jl") end
@time @testset "Fuzzy Weighted Averages" begin include("FuzzyWeightedAverages.jl") end
end