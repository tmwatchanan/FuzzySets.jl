module FuzzySets

name() = return "FuzzySets.jl"

using Plots
using LaTeXStrings

include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("IntervalArithmetic.jl")
include("FuzzyWeightedAverages.jl")

export
    FuzzyNumber, FuzzyVector,
    peak_at, draw,
    fuzzy_weighted_average

end
