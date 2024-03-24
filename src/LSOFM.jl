function find_winning_neuron(X⃗::FuzzyVector, W⃗::Matrix{FuzzyVector})
    I, J = size(W⃗)

    D_squared = [d_dsw(X⃗, W⃗[i, j], squared=true) for i in 1:I, j in 1:J]

    argmin(centroid.(D_squared))
end

function lsofm_find_distances(iₓ, N₁, N₂)
    d_squared = [
        sum(([i, j] - iₓ) .^ 2)
        for i = 1:N₁,
        j = 1:N₂
    ]
    d_squared
end

function lsofm_update_weight(w⃗::FuzzyVector, x⃗::FuzzyVector; η::Real, h::Real)
    levels = w⃗[1].levels
    num_levels = length(levels)
    p = length(w⃗)

    if h == 0 # not in the neighbor
        return w⃗
    end

    if w⃗ == x⃗
        return w⃗
    else
        w⃗_new = Vector{FuzzyNumber}(undef, p)
        for i = 1:p
            grades = Vector{Interval}(undef, num_levels)
            for (lvl, α) in enumerate(levels)
                w⃗_cut = cut(w⃗[i], α)
                x⃗_cut = cut(x⃗[i], α)
                grades[lvl] = lsofm_update_weight(w⃗_cut, x⃗_cut; η=η)
            end
            w⃗_new[i] = FuzzyNumber(levels, grades)
        end
        return FuzzyVector(w⃗_new)
    end
end

function lsofm_update_weight(w::Interval, x::Interval; η::Real)
    num_endpoints = 2 # one for x and another for w

    w_min = Inf
    w_max = -Inf
    for idx_endpoint = 1:2^num_endpoints
        endpoints = get_sequential_endpoints(num_endpoints, idx_endpoint)
        w_new = w[endpoints[2]] + (η * (x[endpoints[1]] - w[endpoints[2]]))

        w_min = min(w_min, w_new)
        w_max = max(w_max, w_new)
    end
    Interval(w_min, w_max)
end

function lsofm_iterate(pattern, 𝑾, η, radius)
    N₁, N₂ = size(𝑾)

    index::CartesianIndex = FuzzySets.find_winning_neuron(pattern, 𝑾)
    iₓ::Vector{Int64} = [index[1], index[2]]

    d_squared = lsofm_find_distances(iₓ, N₁, N₂)
	h(d², radius) = d² <= radius
    𝑯 = h.(d_squared, radius)

    return [
        FuzzySets.lsofm_update_weight(𝑾[i, j], pattern; η=η, h=𝑯[i, j])
        for i = 1:N₁,
        j = 1:N₂
    ]
end