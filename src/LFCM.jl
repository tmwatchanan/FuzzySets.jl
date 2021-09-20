function d(A⃗::FuzzyVector, B⃗::FuzzyVector)
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
	m <= 0 && error("fuzzifier m ∈ (1, ∞)")
	h = 1 / (1 - m)

	num_levels = length(X⃗[1].levels)
	C = length(fuzzy_distances)
	u⃗ = Vector{FuzzyNumber}(undef, C)
	for i = 1:C
		membership_grades = Vector{Interval}(undef, num_levels)
		for lvl = 1:num_levels
			∑₁ = 0
			∑₂ = 0
			for k = 1:C
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
		u⃗[i] = FuzzyNumber(X⃗[1].levels, membership_grades)
	end
	FuzzyVector(u⃗)
end