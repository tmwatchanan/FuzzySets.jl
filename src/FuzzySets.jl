module FuzzySets

name() = return "FuzzySets.jl"

using Plots

include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("IntervalArithmetic.jl")
include("FuzzyWeightedAverages.jl")

end
