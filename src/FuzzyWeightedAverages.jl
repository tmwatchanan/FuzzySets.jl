function getcombinations(patterns, weights)
	N = 2length(patterns)
	inners = 2 .^ collect(0:N-1)
	outers = reverse(inners)
	variables = [patterns; weights]
	combs = []
	# println("-----------------------")
	for (inner, outer, var) in zip(inners, outers, variables)
		# println("inner ", inner, " outer ", outer, " var ", var[1])
		c = repeat(var, inner=inner, outer=outer)
		if isempty(combs)
			combs = c
		else
			combs = hcat(combs, c)
		end
	end
	# println("-----------------------")
	return combs
end

function fwa(levelendpoints)
	# println("=====")
	n = Int(size(levelendpoints)[2] / 2)
	averages = []
	for endpoints in eachrow(levelendpoints)
		numerator = 0
		denominator = 0
		for i = 1:n
			j = i + n
			x = endpoints[i]
			w = endpoints[j]
			# println("i=", i, " | ", "x=", x, ",w=", w, " = ", x*w)
			numerator += x * w
			denominator += w
			if numerator > 10
				# println("numerator=", numerator)
			end
		end
		# println("num=",numerator, " denom=", denominator)
		avg = denominator == 0 ? nothing : numerator / denominator
		if !isnothing(avg)
			push!(averages, avg)
		end
	end
	# println("averages=", averages)
	return [minimum(averages), maximum(averages)]
end
