function d(A⃗::FuzzyVector, B⃗::FuzzyVector; width::Real=0.5)
	if A⃗ == B⃗
		𝟎 = SingletonFuzzyNumber(A⃗[1].levels, number=0)
		return 𝟎
	elseif length(A⃗) ≠ length(B⃗)
		return false
	end
	num_levels = length(A⃗[1].levels)
	distance_grades = Vector{Interval}(undef, num_levels)
	for lvl = 1:num_levels
		d = Interval(0)
		for i = 1:length(A⃗)
			a = A⃗[i][lvl]
			b = B⃗[i][lvl]
			d += (a - b) ^ 2
		end
		d ^= 1 / 2
		distance_grades[lvl] = d
	end
	FuzzyNumber(A⃗[1].levels, distance_grades)
end

function LFCM_u(X⃗::FuzzyVector, fuzzy_distances::Vector{FuzzyNumber}; m::Real=1.5)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	h = 1 / (1 - m)
	c = length(fuzzy_distances)
	levels = X⃗[1].levels
	num_levels = length(levels)

	I = Int64[]
	𝟎 = SingletonFuzzyNumber(levels, number=0)
	for i = 1:c
		if fuzzy_distances[i] == 𝟎
			push!(I, i)
		end
	end

	u⃗ = Vector{FuzzyNumber}(undef, c)
	if isempty(I)
		for i = 1:c
			membership_grades = Vector{Interval}(undef, num_levels)
			for lvl = 1:num_levels
				∑₁ = 0
				∑₂ = 0
				for k = 1:c
					if k == i continue end
					dⱼₖʰ = fuzzy_distances[k][lvl] ^ h
					∑₁ += dⱼₖʰ.left
					∑₂ += dⱼₖʰ.right
				end
				dⱼᵢʰ = fuzzy_distances[i][lvl] ^ h
				u₁ = (dⱼᵢʰ.left) / (dⱼᵢʰ.left + ∑₁)
				u₂ = (dⱼᵢʰ.right) / (dⱼᵢʰ.right + ∑₂)

				membership_grades[lvl] = Interval(u₁, u₂)
			end
			u⃗[i] = FuzzyNumber(levels, membership_grades)
		end
	else
		for i = 1:c
			if i ∉ I
				u⃗[i] = 𝟎
			else
				β = SingletonFuzzyNumber(levels, number=1 / length(I))
				u⃗[i] = β
			end
		end
	end

	u⃗
end

function update_prototype(patterns::Vector{FuzzyVector}, u::Vector{FuzzyNumber}; m::Real=1.5)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	num_levels = length(patterns[1][1].levels)
	N = length(patterns)

	for j = 1:length(patterns[1]) # each dimension j
		membership_grades = Vector{Interval}(undef, num_levels)
		for lvl = 1:num_levels
			sum_numerator = Interval(0)
			for k = 1:N
				println("u ", u[k][lvl])
				sum_numerator += (u[k][lvl])^2
			end
			membership_grades[lvl] = Interval()
		end
	end

	C⃗ = FuzzyVector([])
	C⃗
end