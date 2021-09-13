using FuzzySets, Test

a₁ = 2
a₂ = 5
w₁ = 0.25
w₂ = 0.75
A₁ = FuzzySets.FuzzyNumber(levels, number=a₁)
A₂ = FuzzySets.FuzzyNumber(levels, number=a₂)
W₁ = FuzzySets.FuzzyNumber(levels, number=w₁)
W₂ = FuzzySets.FuzzyNumber(levels, number=w₂)

pp = []
ww = []
for i = 1:length(A₁)
    push!(pp, [A₁[i], A₂[i]])
    push!(ww, [W₁[i], W₂[i]])
end

combinations = FuzzySets.getcombinations.(pp, ww)
FWA = FuzzySets.fwa.(combinations)