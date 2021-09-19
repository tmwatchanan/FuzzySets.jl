function getcombinations(patterns::Vector{Interval}, weights::Vector{Interval})
	N = 2length(patterns)
	inners = 2 .^ collect(0:N-1)
	outers = reverse(inners)
	variables = [patterns; weights]
	combs = Float64[]
	for (inner, outer, var) in zip(inners, outers, variables)
		endpoints = [var.left, var.right]
		c = repeat(endpoints, inner=inner, outer=outer)
		if Base.isempty(combs)
			combs = c
		else
			combs = hcat(combs, c)
		end
	end
	return combs
end

function fwa(levelendpoints::Matrix{Float64})
	n = Int(size(levelendpoints)[2] / 2)
	averages = []
	for endpoints in eachrow(levelendpoints)
		numerator = 0
		denominator = 0
		for i = 1:n
			j = i + n
			x = endpoints[i]
			w = endpoints[j]
			numerator += x * w
			denominator += w
		end
		avg = denominator == 0 ? nothing : numerator / denominator
		if !isnothing(avg)
			push!(averages, avg)
		end
	end
	return Interval(minimum(averages), maximum(averages))
end

function fuzzy_weighted_average(X⃗::FuzzyVector, W⃗::FuzzyVector)
	#FIXME: more than 2-d patterns
	# pattern_vectors = [X.grades for X in X⃗.numbers]
	# weight_vectors = [W.grades for W in W⃗.numbers]

	xx = []
	ww = []
	A₁ = X⃗.numbers[1]
	A₂ = X⃗.numbers[2]
	W₁ = W⃗.numbers[1]
	W₂ = W⃗.numbers[2]
	for i = 1:length(A₁)
		push!(xx, [A₁.grades[i], A₂.grades[i]])
		push!(ww, [W₁.grades[i], W₂.grades[i]])
	end

	combinations = FuzzySets.getcombinations.(xx, ww)
	grades = FuzzySets.fwa.(combinations)
	return FuzzySets.FuzzyNumber(A₁.levels, grades)
end