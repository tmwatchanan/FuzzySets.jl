struct FuzzyVector
    numbers::Vector{FuzzyNumber}
end

Base.length(FV::FuzzyVector) = size(FV.numbers, 1)
Base.getindex(FV::FuzzyVector, i::Int64) = FV.numbers[i]
Base.show(io::IO, FV::FuzzyVector) = println(io, "fuzzy vector length $(length(FV))")
Base.iterate(FV::FuzzyVector, state=1) = state > length(FV.numbers) ? nothing : FV.numbers[state]

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

function draw(ax::Axis3, FV::FuzzyVector; step=0.001, colormap=:jet1)
	A₁ = FV[1]
	A₂ = FV[2]
	X = collect(-4:step:4)
	Y = collect(-3:step:3)
	# X = collect(A₁.grades[1][1]:step:A₁.grades[1][2])
	# Y = collect(A₂.grades[1][1]:step:A₂.grades[1][2])
	Z = [min(A₁(x), A₂(y)) for x in X, y in Y]
	surface!(ax, X, Y, Z, colormap=colormap, axis=(type=Axis3,))
	
    # marking peak
	# max_indices = argmax(Z)
	# max_x = X[max_indices[1]]
	# max_y = Y[max_indices[2]]
	# μ = Z[max_indices]
    # annotate!(fig, [(max_x, max_y, μ, (μ, 8, :black, :center))])
end

function draw2d(FV::FuzzyVector; step::Float64=0.01, fig=nothing, c=:jet1, alpha::Real=nothing, marker::Symbol=nothing, peak_text::Bool=false)
	A₁ = FV[1]
	A₂ = FV[2]
	x1 = max(A₁.grades[1].left, -3.5)
	x2 = min(A₁.grades[1].right, 3.5)
	y1 = max(A₂.grades[1].left, -3.5)
	y2 = min(A₂.grades[1].right, 3.5)
	X = collect(x1:step:x2)
	Y = collect(y1:step:y2)
	f(x, y) = min(A₁(x), A₂(y))
	if isnothing(fig)
		fig = Plots.contour(X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true, dpi=600)
	else
		fig = Plots.contour!(fig, X, Y, f, c=c, aspect_ratio=1.0, seriesalpha=alpha, fill=true, dpi=600)
	end

	# plot peak
	Z = [f(x, y) for x in X, y in Y]
	max_indices = argmax(Z)
	max_x = X[max_indices[1]]
	max_y = Y[max_indices[2]]
	if !isnothing(marker)
		fig = Plots.scatter!(fig, (max_x, max_y), legend=false, m=marker)
	end
	if peak_text
		fig = Plots.annotate!(fig, [(max_x, max_y, ("$(round(max_x, digits=2)), $(round(max_y, digits=2))", 8, :black, :center))])
	end

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