struct FuzzyVector
    numbers::Vector{FuzzyNumber}
end

Base.length(FV::FuzzyVector) = size(FV.numbers, 1)
Base.getindex(FV::FuzzyVector, i::Int64) = FV.numbers[i]
Base.show(io::IO, FV::FuzzyVector) = println(io, "fuzzy vector length $(length(FV))")
Base.iterate(FV::FuzzyVector, state=1) = state > length(FV.numbers) ? nothing : FV.numbers[state]

# FUZZY ARITHMETIC ============================================================
function Base.:+(A⃗::FuzzyVector, B⃗::FuzzyVector)
	p = length(A⃗)
	result_vector = Vector{FuzzyNumber}(undef, p)
	for k = 1:p
		result_vector[k] = A⃗[k] + B⃗[k]
	end
	FuzzyVector(result_vector)
end
function Base.:-(A⃗::FuzzyVector)
	p = length(A⃗)
	result_vector = Vector{FuzzyNumber}(undef, p)
	for k = 1:p
		result_vector[k] = -A⃗[k]
	end
	FuzzyVector(result_vector)
end
Base.:-(A⃗::FuzzyVector, B⃗::FuzzyVector) = A⃗ + (-B⃗)
# =============================================================================

function Base.:(==)(A⃗::FuzzyVector, B⃗::FuzzyVector)
    if length(A⃗) != length(B⃗)
        return false
    end
    for i = 1:length(A⃗)
        if A⃗[i] != B⃗[i]
            return false
        end
    end
    return true
end

function Base.:∪(FV::FuzzyVector, vec::Vector{FuzzyNumber})
   append!(FV.numbers, vec)
   return FV
end

function cut(X::FuzzyVector, α::Real)
	p = length(X)
	cuts = Vector{Interval}(undef, p)
	for j = 1:p
		cuts[j] = cut(X[j], α)
	end
	cuts
end

function cut(X::Vector{FuzzyVector}, p::Int, α::Real)
	N = length(X)
	cuts = Vector{Interval}(undef, N)
	for i = 1:N
		cuts[i] = cut(X[i][p], α)
	end
	cuts
end

function cut(X::Vector{FuzzyVector}, α::Real)
	N = length(X)
	p = length(X[1])
	cuts = Vector{Vector{Interval}}(undef, N)
	for i = 1:N
		cuts[i] = [cut(X[i][j], α) for j = 1:p]
	end
	cuts
end

function draw(ax::Axis3, FV::FuzzyVector; step=0.001, colormap=:jet1)
	A₁ = FV[1]
	A₂ = FV[2]
	X = collect(-4:step:4)
	Y = collect(-3:step:3)
	# X = collect(A₁.grades[1][1]:step:A₁.grades[1][2])
	# Y = collect(A₂.grades[1][1]:step:A₂.grades[1][2])
	Z = [min(A₁(x), A₂(y)) for x in X, y in Y]
	surface!(ax, X, Y, Z, colormap=colormap)#, axis=(type=Axis3,))
	
    # marking peak
	# max_indices = argmax(Z)
	# max_x = X[max_indices[1]]
	# max_y = Y[max_indices[2]]
	# μ = Z[max_indices]
    # annotate!(fig, [(max_x, max_y, μ, (μ, 8, :black, :center))])
end

function draw2d(FV::FuzzyVector; step::Float64=0.01, fig=nothing, c=:jet1, alpha::Real=nothing, marker=nothing, peak_text::Bool=false, font=Plots.font("Times", 8), colorbar::Bool=true)
    gr(xtickfont=font, ytickfont=font, legendfont=font)
	A₁ = FV[1]
	A₂ = FV[2]
	# x1 = max(A₁.grades[1].left, -3.5)
	# x2 = min(A₁.grades[1].right, 3.5)
	# y1 = max(A₂.grades[1].left, -3.5)
	# y2 = min(A₂.grades[1].right, 3.5)
	x1 = A₁.grades[1].left
	x2 = A₁.grades[1].right
	y1 = A₂.grades[1].left
	y2 = A₂.grades[1].right
	X = collect(x1:step:x2)
	Y = collect(y1:step:y2)
	f(x, y) = min(A₁(x), A₂(y))
	if isnothing(fig)
		fig = Plots.contour(X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true)
	else
		fig = Plots.contour(fig, X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true)
		# fig = Plots.contour(fig, [0, 0], [0, 0], [0, 1], c=c, aspect_ratio=1.0, seriesalpha=1.0, fill=true, colorbar=colorbar)
	end

	# plot peak
	center_x = peak_center(A₁) # or can be centroid()
	center_y = peak_center(A₂) # or can be centroid()
	if !isnothing(marker)
		fig = Plots.scatter(fig, (center_x, center_y), legend=false, m=marker, color=:grey)
	end
	if peak_text
		Plots.annotate!([(center_x, center_y, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, :black, :center))])
	end

	fig = Plots.plot(fig, dpi=200)
	fig
end

function draw_contour_2d(FVs::Vector{FuzzyVector}; step::Float64=0.01, fig=nothing, contour_colors=[:jet1, :jet1], peak_colors=["black", "red"], alpha::Vector{Float64}=nothing, marker=nothing, peak_text::Bool=false, offset::Real=0, xlim=nothing, ylim=nothing, font=Plots.font("Times", 8), colorbar::Bool=true)
    gr(xtickfont=font, ytickfont=font, legendfont=font)

	centers = []
	for (i, FV) in enumerate(FVs)
		A₁ = FV[1]
		A₂ = FV[2]
		x1 = A₁.grades[1].left
		x2 = A₁.grades[1].right
		y1 = A₂.grades[1].left
		y2 = A₂.grades[1].right
		X = collect(x1:step:x2)
		Y = collect(y1:step:y2)
		f(x, y) = min(A₁(x), A₂(y))
		center_x = peak_center(A₁) # or can be centroid()
		center_y = peak_center(A₂) # or can be centroid()
		push!(centers, (center_x, center_y))
		if isnothing(fig)
			fig = Plots.contour(X, Y, f, c=contour_colors[i], aspect_ratio=1.0, seriesalpha=alpha[i], xlim=xlim, ylim=ylim, fill=true)
		else
			fig = Plots.contour(fig, X, Y, f, c=contour_colors[i], aspect_ratio=1.0, seriesalpha=alpha[i], fill=true, xlim=xlim, ylim=ylim)
			fig = Plots.contour(fig, [0, 0], [0, 0], [0, 1], c=contour_colors[i], aspect_ratio=1.0, seriesalpha=1.0, fill=true, colorbar=colorbar, xlim=xlim, ylim=ylim)
		end
	end

	# plot peak
	for (i, (center_x, center_y)) in enumerate(centers)
		if !isnothing(marker)
			fig = Plots.scatter(fig, (center_x, center_y), legend=false, m=marker, c=peak_colors[i])
		end
		if peak_text
			# fig = Plots.annotate(fig, [(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
			Plots.annotate!([(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
		end
	end

	fig = Plots.plot(fig, dpi=200)
	fig
end

function draw_3d(FVs::Vector{FuzzyVector}; step::Float64=0.01, fig=nothing, color=:grey, alpha::Float64=nothing, peak_text::Bool=false, offset::Real=0, xlim=nothing, ylim=nothing, font=Plots.font("Times", 8))
	centers = []
	for (i, FV) in enumerate(FVs)
		A₁ = FV[1]
		A₂ = FV[2]
		x1 = A₁.grades[1].left
		x2 = A₁.grades[1].right
		y1 = A₂.grades[1].left
		y2 = A₂.grades[1].right
		X = collect(x1:step:x2)
		Y = collect(y1:step:y2)
		f(x, y) = min(A₁(x), A₂(y))
		center_x = peak_center(A₁) # or can be centroid()
		center_y = peak_center(A₂) # or can be centroid()
		push!(centers, (center_x, center_y))
		fig = Plots.surface(fig, X, Y, f, aspect_ratio=1.0, color=color, alpha=alpha, fill=true, xlim=xlim, ylim=ylim)
		# fig = Plots.surface(fig, [0, 0], [0, 0], [0, 1], c=color, aspect_ratio=1.0, alpha=1.0, fill=true, colorbar=true, xlim=xlim, ylim=ylim)
	end

	# plot peak
	# for (i, (center_x, center_y)) in enumerate(centers)
	# 	if peak_text
	# 		# fig = Plots.annotate(fig, [(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
	# 		Plots.annotate!([(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
	# 	end
	# end

	fig = Plots.plot(fig, dpi=200)
	fig
end

function draw_center_3d(FVs::Vector{FuzzyVector}; step::Float64=0.01, fig=nothing, contour_colors=[:jet1, :jet1], peak_colors=["black", "red"], alpha::Vector{Float64}=nothing, marker=nothing, peak_text::Bool=false, offset::Real=0, xlim=nothing, ylim=nothing, font=Plots.font("Times", 8))
	centers = []
	for (i, FV) in enumerate(FVs)
		A₁ = FV[1]
		A₂ = FV[2]
		x1 = A₁.grades[1].left
		x2 = A₁.grades[1].right
		y1 = A₂.grades[1].left
		y2 = A₂.grades[1].right
		X = collect(x1:step:x2)
		Y = collect(y1:step:y2)
		f(x, y) = min(A₁(x), A₂(y))
		center_x = peak_center(A₁) # or can be centroid()
		center_y = peak_center(A₂) # or can be centroid()
		push!(centers, (center_x, center_y))
		fig = Plots.surface(fig, X, Y, f, c=contour_colors[i], aspect_ratio=1.0, seriesalpha=alpha[i], fill=true, xlim=xlim, ylim=ylim)
		fig = Plots.surface(fig, [0, 0], [0, 0], [0, 1], c=contour_colors[i], aspect_ratio=1.0, seriesalpha=1.0, fill=true, colorbar=true, xlim=xlim, ylim=ylim)
	end

	# plot peak
	# for (i, (center_x, center_y)) in enumerate(centers)
	# 	if !isnothing(marker)
	# 		fig = Plots.scatter(fig, (center_x, center_y), legend=false, m=marker, c=peak_colors[i])
	# 	end
	# 	if peak_text
	# 		# fig = Plots.annotate(fig, [(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
	# 		Plots.annotate!([(center_x, center_y+offset, ("$(round(center_x, digits=2)), $(round(center_y, digits=2))", 8, peak_colors[i], :center, "Times"))])
	# 	end
	# end

	fig = Plots.plot(fig, dpi=200)
	fig
end

function draw2d_makie(ax::Axis, FV::FuzzyVector; step=0.01, colormap=:jet1, alpha=nothing)
	A₁ = FV[1]
	A₂ = FV[2]
	x1 = max(A₁.grades[1].left, -3.5)
	x2 = min(A₁.grades[1].right, 3.5)
	y1 = max(A₂.grades[1].left, -3.5)
	y2 = min(A₂.grades[1].right, 3.5)
	X = collect(x1:step:x2)
	Y = collect(y1:step:y2)
	Z = [min(A₁(x), A₂(y)) for x in X, y in Y]
	contour!(ax, X, Y, Z, colormap=colormap)#, alpha=alpha)
end

function u_uncertainty(FV::FuzzyVector; agg::String="average")
	p = length(FV)
	Us = Vector{Float64}(undef, p)
	for k = 1:p
		Us[k] = u_uncertainty(FV[k])
	end
	if agg == "average"
		return sum(Us) / p
	elseif agg == "max"
		return maximum(Us)
	elseif agg == "sum"
		return sum(Us)
	end
end