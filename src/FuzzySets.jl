module FuzzySets

name() = return "FuzzySets.jl"

using GLMakie
using LaTeXStrings
import Plots
using FLoops

include("Intervals.jl")
include("FuzzySet.jl")
include("FuzzyNumbers.jl")
include("FuzzyVectors.jl")
include("FuzzyWeightedAverages.jl")
include("FCM.jl")
include("IT2FCM.jl")
include("LFCM.jl")

export
    Interval, .., mid, rad,
    FuzzySet, support, core, height, cut,
    FuzzyNumber, SingletonFuzzyNumber, FuzzyVector, 
    peak, draw,
    fuzzy_weighted_average
end
