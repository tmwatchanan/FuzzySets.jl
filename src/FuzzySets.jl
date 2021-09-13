module FuzzySets

name() = return "FuzzySets.jl"

using Plots

include("FuzzyNumbers.jl")
include("IntervalArithmetic.jl")
include("FuzzyWeightedAverages.jl")

end
