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
					if dⱼᵢ != 0
						dⱼᵢ ^= h
					end

					∑ = 0
					for k = 1:c
						C⃗ₖ = prototypes[k]
						dⱼₖ = 0
						for i = 1:p
							c_i = p*k + p
							dⱼₖ += (X⃗[i][lvl][endpoints[i]] - C⃗ₖ[i][lvl][endpoints[c_i]])^2
						end
						dⱼₖ ^= 0.5
						if dⱼₖ != 0
							dⱼₖ ^= h
						end
						∑ += dⱼₖ
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


function km_iwa(X::Vector{Interval}, u::Vector{Interval}; bound::String, m=2.0) # Karnik and Mendel's interval weighted average
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
				println("x_sorted[$k] = $(x_sorted[k]), y′ = $(y′)")
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
        end
        y′ = y_k
    end
    y′
end

function c_karnik(X::Vector{FuzzyVector}, u::Matrix{FuzzyNumber}; m::Real=1.5)
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

				z = Vector{Real}(undef, N)
				# h = Vector{Real}(undef, N)
				for k = 1:N
					# cₖ = mid(X[k][j][lvl])
					# rₖ = rad(X[k][j][lvl])
					# zₖ = cₖ + rₖ
					zₖ = X[k][j][lvl].right
					z[k] = zₖ
					# h[k] = u[k, i][lvl]
				end
				x_sorted = sort(z)

				w = Vector{Real}(undef, N)
				Δ = Vector{Real}(undef, N)
				for k = 1:N
					w[k] = mid(u[k, i][lvl]) # = hₖ
					Δ[k] = rad(u[k, i][lvl])
				end
				S′ = sum(w.^m .* x_sorted) / sum(w.^m)
				S′_prev = copy(S′)

				while true
					_k = 1
					for k = 1:N
						if x_sorted[k] <= S′ 
							_k = k
							break
						end
					end
					w[1:_k] -= Δ[1:_k]
					w[_k+1:end] += Δ[_k+1:end]

					S′ = sum(w.^m .* x_sorted) / sum(w.^m)
					if S′ ≈ S′_prev
						break
					end
					S′_prev = S′
				end
				c_right = copy(S′)

				z = Vector{Real}(undef, N)
				for k = 1:N
					zₖ = X[k][j][lvl].left
					z[k] = zₖ
				end
				x_sorted = sort(z)

				w = Vector{Real}(undef, N)
				Δ = Vector{Real}(undef, N)
				for k = 1:N
					w[k] = mid(u[k, i][lvl]) # = hₖ
					Δ[k] = rad(u[k, i][lvl])
				end
				S′ = sum(w.^m .* x_sorted) / sum(w.^m)
				S′_prev = copy(S′)

				while true
					_k = 1
					for k = 1:N
						if x_sorted[k] <= S′ 
							_k = k
							break
						end
					end
					w[1:_k] += Δ[1:_k]
					w[_k+1:end] -= Δ[_k+1:end]

					S′ = sum(w.^m .* x_sorted) / sum(w.^m)
					if S′ ≈ S′_prev
						break
					end
					S′_prev = S′
				end
				c_left = copy(S′)

				grades[lvl] = Interval(c_left, c_right)
			end
			C⃗[j] = FuzzyNumber(levels, grades)
		end
		C[i] = FuzzyVector(C⃗)
	end
	C
end

function d_interval(A⃗::FuzzyVector, B⃗::FuzzyVector)
	if A⃗ == B⃗
		𝟎 = SingletonFuzzyNumber(A⃗[1].levels, number=0)
		return 𝟎
	elseif length(A⃗) ≠ length(B⃗)
		return false
	end

	p = length(A⃗)
	levels = A⃗[1].levels
	num_levels = length(levels)
	distance_grades = Vector{Interval}(undef, num_levels)
	for lvl = 1:num_levels
		d = Interval(0)
		for i = 1:p
			a = A⃗[i][lvl]
			b = B⃗[i][lvl]
			d += ((a - b) ^ 2)
		end
		d ^= 0.5
		distance_grades[lvl] = d
	end
	FuzzyNumber(levels, distance_grades)
end

function u_interval(X⃗::FuzzyVector, fuzzy_distances::Vector{FuzzyNumber}; m::Real=1.5)
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
				dⱼᵢʰ = fuzzy_distances[i][lvl] ^ h
				∑dⱼₖʰ = Interval(0)
				for k = 1:c
					∑dⱼₖʰ += fuzzy_distances[k][lvl] ^ h
				end
				membership_grades[lvl] = dⱼᵢʰ / ∑dⱼₖʰ
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

function c_interval(X⃗::Vector{FuzzyVector}, u::Vector{FuzzyNumber}; m::Real=1.5)
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

function clip(A::FuzzyNumber)
	lvl_02 = Int(floor(length(A.levels) / 5))
	for lvl = 1:lvl_02
		A.grades[lvl] = A.grades[lvl_02 + 1]
	end
	A
end