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

function draw(ax::Axis3, FV::FuzzyVector; step=0.001)
	A₁ = FV[1]
	A₂ = FV[2]
	X = collect(A₁.grades[1][1]:step:A₁.grades[1][2])
	Y = collect(A₂.grades[1][1]:step:A₂.grades[1][2])
	Z = [min(A₁(x), A₂(y)) for x in X, y in Y]
	surface!(ax, X, Y, Z, colormap=:jet1, axis=(type=Axis3,))
	
    # marking peak
	# max_indices = argmax(Z)
	# max_x = X[max_indices[1]]
	# max_y = Y[max_indices[2]]
	# μ = Z[max_indices]
    # annotate!(fig, [(max_x, max_y, μ, (μ, 8, :black, :center))])
end

function draw2d(FV::FuzzyVector; step=0.001, fig=nothing) # TODO:
	A₁ = FV[1]
	A₂ = FV[2]
	X = collect(A₁.grades[1][1]:step:A₁.grades[1][2])
	Y = collect(A₂.grades[1][1]:step:A₂.grades[1][2])
	Z = [min(A₁(x), A₂(y)) for x in X, y in Y]
	if isnothing(fig)
		fig = Plots.contour(X, Y, Z, fill=true, c=:jet1)
	else
		fig = Plots.contour!(fig, X, Y, Z, fill=true, c=:jet1)
	end
	fig
end