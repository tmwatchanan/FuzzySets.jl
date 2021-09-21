module FuzzySets

name() = return "FuzzySets.jl"

using GLMakie
using LaTeXStrings
import Plots

include("Intervals.jl")
include("FuzzySet.jl")
include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("FuzzyWeightedAverages.jl")
include("LFCM.jl")

export
    Interval, .., mid, rad,
    FuzzySet, support, core, height,
    FuzzyNumber, SingletonFuzzyNumber, FuzzyVector, 
    peak_at, draw,
    fuzzy_weighted_average
end
