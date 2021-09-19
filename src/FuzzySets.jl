module FuzzySets

name() = return "FuzzySets.jl"

using GLMakie
using LaTeXStrings

include("Intervals.jl")
include("FuzzySet.jl")
include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("FuzzyWeightedAverages.jl")
include("LFCM.jl")

export
    Interval, .., mid, rad,
    FuzzySet, support, core, height,
    FuzzyNumber, FuzzyVector, 
    peak_at, draw,
    fuzzy_weighted_average
end
