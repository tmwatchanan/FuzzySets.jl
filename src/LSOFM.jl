function find_winning_neuron(X⃗::FuzzyVector, W⃗::Matrix{FuzzyVector})::CartesianIndex
    I, J = size(W⃗)

    D_squared = [d_dsw(X⃗, W⃗[i, j], squared=true) for i in 1:I, j in 1:J]

    argmin(centroid.(D_squared))
end

function lsofm_find_distances(iₓ, N₁, N₂)::Matrix{Float64}
    d_squared = [
        sum(([i, j] - iₓ) .^ 2)
        for i = 1:N₁,
        j = 1:N₂
    ]
    d_squared
end

function lsofm_update_weight(w⃗::FuzzyVector, x⃗::FuzzyVector; η::Real, h::Real, dampening::Union{Nothing, Float64}=nothing)::FuzzyVector
    levels = w⃗[1].levels
    num_levels = length(levels)
    p = length(w⃗)

    if h == 0 # not in the neighbor
        return w⃗
    end

    if w⃗ == x⃗
        return w⃗
    end

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

function lsofm_update_weight(w::Interval, x::Interval; η::Real)::Interval
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

function lsofm_iterate(pattern, 𝑾, η, radius)#::Matrix{FuzzyVector}
    N₁, N₂ = size(𝑾)

    winner_index::CartesianIndex = FuzzySets.find_winning_neuron(pattern, 𝑾)
    iₓ::Vector{Int64} = [winner_index[1], winner_index[2]]

    d_squared::Matrix{Float64} = lsofm_find_distances(iₓ, N₁, N₂)
    h(d², radius) = d² <= radius
    𝑯::BitArray = h.(d_squared, radius)

    updated_𝑾::Matrix{FuzzyVector} = [
        FuzzySets.lsofm_update_weight(𝑾[i, j], pattern; η=η, h=𝑯[i, j])
        for i = 1:N₁,
        j = 1:N₂
    ]

    updated_𝑾, winner_index
end

function plot2d_lsofm(FV::FuzzyVector; step::Float64=0.01, fig=nothing, c=:jet1, alpha::Real=nothing, marker=nothing, peak_text::Bool=false, font=Plots.font("Times", 8), colorbar::Bool=true)
    gr(xtickfont=font, ytickfont=font, legendfont=font)
	A₁ = FV[1]
	A₂ = FV[2]
	x1 = support(A₁).left
	x2 = support(A₁).right
	y1 = support(A₂).left
	y2 = support(A₂).right
	X = collect(x1:step:x2)
	Y = collect(y1:step:y2)
	f(x, y) = min(A₁(x), A₂(y))
	if isnothing(fig)
		fig = Plots.contour(X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true)
	else
		Plots.contour!(fig, X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true)
		# Plots.contour!(fig, [0, 0], [0, 0], [0, 1], c=c, aspect_ratio=1.0, seriesalpha=1.0, fill=true, colorbar=colorbar)
	end

	# plot peak
	center_x = peak_center(A₁) # or can be centroid()
	center_y = peak_center(A₂) # or can be centroid()
	if !isnothing(marker)
		Plots.scatter!(fig, (center_x, center_y), legend=false, m=marker, color=:black)
	end
	if peak_text
		Plots.annotate!([(center_x, center_y, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, :black, :center))])
	end

	Plots.plot!(fig, dpi=200)
	fig
end