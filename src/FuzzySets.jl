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
include("FuzzyMatrices.jl")
include("FuzzyWeightedAverages.jl")
include("FCM.jl")
include("PCM.jl")
include("IT2FCM.jl")
include("Dampening.jl")
include("LFCM.jl")
include("LPCM.jl")

export
    Interval, .., mid, rad,
    FuzzySet, support, core, height, cut, centroid,
    FuzzyNumber, SingletonFuzzyNumber, TriangularFuzzyNumber, TrapezoidalFuzzyNumber, GaussianFuzzyNumber,
    FuzzyVector, 
    peak, draw,
    fuzzy_weighted_average,
    euclidean_distance,
    u_uncertainty
end
