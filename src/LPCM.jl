function η_karnik(u::Matrix{FuzzyNumber}, d2::Matrix{FuzzyNumber}; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞), got $m")
	levels = u[1, 1].levels
	num_levels = length(levels)
	N, c = size(u)

	η = Vector{FuzzyNumber}(undef, c)
	for i = 1:c
		grades = Vector{Interval}(undef, num_levels)
		for (lvl, α) in enumerate(levels)
			u_cut = cut(FuzzyVector(u[:, i]), α)
			d2_cut = cut(FuzzyVector(d2[:, i]), α)
			c_left = km_iwa(d2_cut, u_cut; bound="lower", m=m)
			c_right = km_iwa(d2_cut, u_cut; bound="upper", m=m)
			grades[lvl] = Interval(c_left, c_right)
		end
		η[i] = FuzzyNumber(levels, grades)
	end
	η
end

function u_lpcm(X⃗::FuzzyVector, C⃗::FuzzyVector, η::Real; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞), got $m")
	η > 0 || error("η must be suitable positive number")
	levels = X⃗[1].levels
	num_levels = length(levels)

	grades = Vector{Interval}(undef, num_levels)
	D2 = FuzzySets.d_interval(X⃗, C⃗, squared=true)
	for (lvl, α) in enumerate(levels)
		D2_cut = cut(D2, α)
		grades[lvl] = u_lpcm(D2_cut, η; m=m)
	end
	u = FuzzyNumber(levels, grades)
	u
end

function u_lpcm(d2::Interval, η::Real; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	η > 0 || error("η must be suitable positive number")
	power = 1 / (m - 1)

	u = Interval(1) / (Interval(1) + (d2 / η)^power)
	u
end