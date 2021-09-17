module FuzzySets

name() = return "FuzzySets.jl"

using GLMakie
using LaTeXStrings

include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("IntervalArithmetic.jl")
include("FuzzyWeightedAverages.jl")
include("LFCM.jl")

export
    FuzzyNumber, FuzzyVector,
    peak_at, draw,
    fuzzy_weighted_average

end
