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

function d_dsw(X⃗::FuzzyVector, Y⃗::FuzzyVector)
	levels = X⃗[1].levels
	num_levels = length(levels)
	p = length(X⃗)

	if X⃗ == Y⃗
		d = SingletonFuzzyNumber(levels, number=0)
	elseif length(X⃗) ≠ length(Y⃗)
		return false
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

function u_dsw(X⃗::FuzzyVector, prototypes::Vector{FuzzyVector}; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	levels = X⃗[1].levels
	num_levels = length(levels)
	c = length(prototypes)

	Iⱼ = [i for i = 1:c if X⃗ == prototypes[i]]
	uⱼ = Vector{FuzzyNumber}(undef, c)
	if isempty(Iⱼ) # Iⱼ = ∅
		for i = 1:c
			grades = Vector{Interval}(undef, num_levels)
			for (lvl, α) in enumerate(levels)
				X_cut = cut(X⃗, α)
				C_cut = cut(prototypes,  α)
				grades[lvl] = u_dsw(X_cut, C_cut, i, m=m)
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

function u_dsw(X⃗::Vector{Interval}, prototypes::Vector{Vector{Interval}}, i::Int; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	h = 1 / (1 - m)
	c = length(prototypes)
	p = length(X⃗)

	C⃗ᵢ = prototypes[i]
	num_endpoints = (c + 1) * p

	u_min = Inf
	u_max = -Inf
	for idx_endpoint = 1:2^num_endpoints
		endpoints = sequential_get_endpoints(num_endpoints, idx_endpoint)

		dⱼᵢ = 0
		for j = 1:p
			c_idx = p + (i-1)*p + j
			dⱼᵢ += (X⃗[j][endpoints[j]] - C⃗ᵢ[j][endpoints[c_idx]])^2
		end
		if dⱼᵢ != 0
			dⱼᵢ ^= h
		end

		∑ = 0
		for k = 1:c
			C⃗ₖ = prototypes[k]
			dⱼₖ = 0
			for j = 1:p
				c_idx = p + (k-1)*p + j
				dⱼₖ += (X⃗[j][endpoints[j]] - C⃗ₖ[j][endpoints[c_idx]])^2
			end
			if dⱼₖ != 0
				dⱼₖ ^= h
			end
			∑ += dⱼₖ
		end
		u = ∑ == 0 ? nothing : dⱼᵢ / ∑
		u_min = min(u_min, u)
		u_max = max(u_max, u)
	end
	Interval(u_min, u_max)
end

function u_lfcm(X⃗::Vector{Interval}, prototypes::Vector{Vector{Interval}}, i::Int; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	h = 1 / (1 - m)
	c = length(prototypes)

	djih = d_interval(X⃗[j], prototypes[i], squared=true)

	d2jih = (djih.right)^h
	d1jih = (djih.left)^h

	u_a_denom = d2jih
	u_b_denom = d1jih
	for k = 1:c
		if k != i
			d2jkh = d_interval(X⃗[j], prototypes[k], squared=true)
			u_a_denom += (d2jkh.left)^h
			u_b_denom += (d2jkh.right)^h
		end
	end
	u_a = d2jih / u_a_denom
	u_b = d1jih / u_b_denom

	Interval(u_a, u_b)
end

function c_dsw(X::Vector{FuzzyVector}, u::Matrix{FuzzyNumber}; m::Real=2.0)
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


function km_iwa(X::Vector{Interval}, u::Vector{Interval}; bound::String, m::Real=2.0) # Karnik and Mendel's interval weighted average
    N = size(X, 1)
    x = Vector{Real}(undef, N)
    for k = 1:N
		if bound == "lower"
			x[k] = X[k].left # a_i
		elseif bound == "upper"
			x[k] = X[k].right # b_i
		else
			throw(ArgumentError("bound must be \"lower\" or \"upper\""))
		end
    end
    x_sorted = sort(x)
    sorted_indices = sortperm(x)

    w = Vector{Real}(undef, N)
    c = Vector{Real}(undef, N)
    d = Vector{Real}(undef, N)
    for k = 1:N
        w[k] = mid(u[k])
        c[k] = u[k].left
        d[k] = u[k].right
    end
    y′ = sum(w.^m .* x) / sum(w.^m)

	while true
        _k = 1
        for k = 1:N-1
            if x_sorted[k] <= y′ && y′ <= x_sorted[k+1]
                _k = k
                break
            end
			k = N
        end

		left_indices = sorted_indices[1:_k]
		right_indices = sorted_indices[_k+1:end]
		if bound == "lower"
			w[left_indices] = d[left_indices]
			w[right_indices] = c[right_indices]
		elseif bound == "upper"
			w[left_indices] = c[left_indices]
			w[right_indices] = d[right_indices]
		end

        y_k = sum(w.^m .* x) / sum(w.^m)
        if y′ ≈ y_k
            break
		else
			println("$y′ is not equal to $y_k")
        end
        y′ = y_k
    end
    y′
end

function c_karnik(X::Vector{FuzzyVector}, u::Matrix{FuzzyNumber}; m::Real=2.0)
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
			for (lvl, α) in enumerate(levels)
				X_cut = cut(X, j, α)
				u_cut = cut(FuzzyVector(u[:, i]), α)
				c_left = km_iwa(X_cut, u_cut; bound="lower", m=m)
				c_right = km_iwa(X_cut, u_cut; bound="upper", m=m)
				grades[lvl] = Interval(c_left, c_right)
			end
			C⃗[j] = FuzzyNumber(levels, grades)
		end
		C[i] = FuzzyVector(C⃗)
	end
	C
end

function d_interval(A⃗::FuzzyVector, B⃗::FuzzyVector; squared::Bool=false)
	if A⃗ == B⃗
		𝟎 = SingletonFuzzyNumber(A⃗[1].levels, number=0)
		return 𝟎
	elseif length(A⃗) ≠ length(B⃗)
		return false
	end

	levels = A⃗[1].levels
	num_levels = length(levels)

	grades = Vector{Interval}(undef, num_levels)
	for (lvl, α) in enumerate(levels)
		A_cut = cut(A⃗, α)
		B_cut = cut(B⃗, α)
		grades[lvl] = d_interval(A_cut, B_cut; squared=squared)
	end
	FuzzyNumber(levels, grades)
end

function d_interval(A⃗::Vector{Interval}, B⃗::Vector{Interval}; squared::Bool=false)
	p = length(A⃗)

	d = Interval(0)
	for i = 1:p
		d += (A⃗[i] - B⃗[i])^2
	end
	if (!squared) d ^= 0.5 end

	d
end

function u_interval(squared_fuzzy_distances::Vector{FuzzyNumber}; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	c = length(squared_fuzzy_distances)
	levels = squared_fuzzy_distances[1].levels
	num_levels = length(levels)

	I = Int64[]
	𝟎 = SingletonFuzzyNumber(levels, number=0)
	for i = 1:c
		if squared_fuzzy_distances[i] == 𝟎
			push!(I, i)
		end
	end

	u⃗ = Vector{FuzzyNumber}(undef, c)
	if isempty(I)
		for i = 1:c
			grades = Vector{Interval}(undef, num_levels)
			for (lvl, α) in enumerate(levels)
				d²_cut = cut(squared_fuzzy_distances, α)
				grades[lvl] = u_interval(d²_cut, i; m=m)
			end
			u⃗[i] = FuzzyNumber(levels, grades)
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

function u_interval(squared_fuzzy_distances::Vector{Interval}, i::Int; m::Real=2.0)
	h = 1 / (1 - m)
	squared_fuzzy_distances[i]^h / sum(squared_fuzzy_distances.^h)
end

function c_interval(X⃗::Vector{FuzzyVector}, u::Vector{FuzzyNumber}; m::Real=2.0)
	m > 1 || error("fuzzifier m ∈ (1, ∞)")
	levels = X⃗[1][1].levels
	num_levels = length(levels)
	N = length(X⃗)
	p = length(X⃗[1])

	C⃗ = Vector{FuzzyNumber}(undef, p)
	for j = 1:p # each dimension j
		membership_grades = Vector{Interval}(undef, num_levels)
		for lvl = 1:num_levels
			sum_numerator = Interval(0)
			sum_denominator = Interval(0)
			for k = 1:N
				sum_numerator += (u[k][lvl]^m * X⃗[k][j][lvl])
				sum_denominator += u[k][lvl]^m
			end
			membership_grades[lvl] = sum_numerator / sum_denominator
		end
		C⃗[j] = FuzzyNumber(levels, membership_grades)
	end
	C⃗ = FuzzyVector(C⃗)
	C⃗
end