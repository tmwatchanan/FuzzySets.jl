function get_endpoints(N)
	inners = 2 .^ collect(0:N-1)
	outers = reverse(inners)
	combs = Float64[]
	for (inner, outer) in zip(inners, outers)
		endpoints = [1, 2]
		c = repeat(endpoints, inner=inner, outer=outer)
		if Base.isempty(combs)
			combs = c
		else
			combs = hcat(combs, c)
		end
	end
	return combs
end

sequential_get_endpoints(N, i) = digits(i-1, base=2, pad=N) .+ 1

function d_interval(X⃗::FuzzyVector, Y⃗::FuzzyVector)
	levels = X⃗[1].levels
	num_levels = length(levels)
	p = length(X⃗)

	grades = Vector{Interval}(undef, num_levels)
	for lvl = 1:num_levels
		d_left = 0
		d_right = 0
		for i = 1:p
			d_left += (X⃗[i][lvl][1] - Y⃗[i][lvl][2])^2
			d_right += (X⃗[i][lvl][2] - Y⃗[i][lvl][1])^2
		end
		d_left ^= 0.5
		d_right ^= 0.5
		grades[lvl] = Interval(d_left, d_right)
	end
	d = FuzzyNumber(levels, grades)
	d
end


function d_dsw(X⃗::FuzzyVector, Y⃗::FuzzyVector)
	levels = X⃗[1].levels
	num_levels = length(levels)
	p = length(X⃗)

	if X⃗ == Y⃗
		d = SingletonFuzzyNumber(levels, number=0)
	else
		grades = Vector{Interval}(undef, num_levels)
		for lvl = 1:num_levels
			num_endpoints = 2 * p

			d_min = Inf
			d_max = -Inf
			for idx_endpoint = 1:2^num_endpoints
				endpoints = sequential_get_endpoints(num_endpoints, idx_endpoint)
				dⱼᵢ = 0
				for i = 1:p
					dⱼᵢ += (X⃗[i][lvl][endpoints[i]] - Y⃗[i][lvl][endpoints[p + i]])^2
				end
				dⱼᵢ ^= 0.5

				d_min = min(d_min, dⱼᵢ)
				d_max = max(d_max, dⱼᵢ)
			end
			grades[lvl] = Interval(d_min, d_max)
		end
		d = FuzzyNumber(levels, grades)
	end
	d
end


function u_dsw(X⃗::FuzzyVector, prototypes::Vector{FuzzyVector}; m::Real=1.5)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	h = 1 / (1 - m)
	levels = X⃗[1].levels
	num_levels = length(levels)
	c = length(prototypes)
	p = length(X⃗)

	Iⱼ = [i for i = 1:c if X⃗ == prototypes[i]]
	uⱼ = Vector{FuzzyNumber}(undef, c)
	if isempty(Iⱼ) # Iⱼ = ∅
		for i = 1:c
			C⃗ᵢ = prototypes[i]
			grades = Vector{Interval}(undef, num_levels)
			for lvl = 1:num_levels
				num_endpoints = (c + 1) * p

				u_min = Inf
				u_max = -Inf
				for idx_endpoint = 1:2^num_endpoints
					endpoints = sequential_get_endpoints(num_endpoints, idx_endpoint)

					dⱼᵢ = 0
					for i = 1:p
						c_i = p*i + p
						dⱼᵢ += (X⃗[i][lvl][endpoints[i]] - C⃗ᵢ[i][lvl][endpoints[c_i]])^2
					end
					dⱼᵢ ^= 0.5
					dⱼᵢ ^= h

					∑ = 0
					for k = 1:c
						C⃗ₖ = prototypes[k]
						dⱼₖ = 0
						for i = 1:p
							c_i = p*k + p
							dⱼₖ += (X⃗[i][lvl][endpoints[i]] - C⃗ₖ[i][lvl][endpoints[c_i]])^2
						end
						∑ += (dⱼₖ ^ 0.5) ^ h
					end
					u = ∑ == 0 ? nothing : dⱼᵢ / ∑
					u_min = min(u_min, u)
					u_max = max(u_max, u)
				end
				grades[lvl] = Interval(u_min, u_max)
			end
			uⱼ[i] = FuzzyNumber(levels, grades)
		end
	else # Iⱼ ≠ ∅
		for i = 1:c
			if i ∉ Iⱼ
				uⱼ[i] = SingletonFuzzyNumber(levels, number=0)
			else
				uⱼ[i] = SingletonFuzzyNumber(levels, number=1 / length(Iⱼ))
			end
		end
	end
	uⱼ
end

function c_dsw(X::Vector{FuzzyVector}, u::Matrix{FuzzyNumber}; m::Real=1.5)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	levels = X[1][1].levels
	num_levels = length(levels)
	N, c = size(u)
	p = length(X[1])

	C = Vector{FuzzyVector}(undef, c)
	for i = 1:c
		C⃗ = Vector{FuzzyNumber}(undef, p)
		for j = 1:p
			grades = Vector{Interval}(undef, num_levels)
			for lvl = 1:num_levels
				num_endpoints = N + N

				c_min = Inf
				c_max = -Inf
				@floop for idx_endpoint = 1:2^num_endpoints
					endpoints = sequential_get_endpoints(num_endpoints, idx_endpoint)
					numerator = 0
					for k = 1:N
						u_i = N + k
						numerator += u[k, i][lvl][endpoints[u_i]]^m * X[k][j][lvl][endpoints[k]]
					end

					∑ = 0
					for k = 1:N
						u_i = N + k
						∑ += u[k, i][lvl][endpoints[u_i]]
					end
					cᵢⱼ = ∑ == 0 ? nothing : numerator / ∑
					@reduce() do (c_min; cᵢⱼ)
						if cᵢⱼ < c_min
							c_min = cᵢⱼ
						end
					end
					@reduce() do (c_max; cᵢⱼ)
						if cᵢⱼ > c_max
							c_max = cᵢⱼ
						end
					end
				end
				grades[lvl] = Interval(c_min, c_max)
			end
			C⃗[j] = FuzzyNumber(levels, grades)
		end
		C[i] = FuzzyVector(C⃗)
	end
	C
end

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