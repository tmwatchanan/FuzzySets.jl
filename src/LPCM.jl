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

function u_lpcm(X⃗::FuzzyVector, prototypes::FuzzyVector, η::FuzzyNumber; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞), got $m")
	peak(η) > 0 || error("η must be suitable positive number, got $(peak(η))")
	levels = X⃗[1].levels
	num_levels = length(levels)

	grades = Vector{Interval}(undef, num_levels)
	for (lvl, α) in enumerate(levels)
		X_cut = cut(X⃗, α)
		C_cut = cut(prototypes,  α)
		η_cut = cut(η, α)
		grades[lvl] = u_lpcm(X_cut, C_cut, η_cut, m=m)
	end
	u = FuzzyNumber(levels, grades)
	u
end

function u_lpcm(X⃗::Vector{Interval}, prototypes::Vector{Interval}, η::Interval; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	η.left >= 0 || error("η must be suitable positive number")
	power = 1 / (m - 1)

	d2 = d_interval(X⃗, prototypes, squared=true)
	u = Interval(1) / (Interval(1) + (d2 / η)^power)
	u
end