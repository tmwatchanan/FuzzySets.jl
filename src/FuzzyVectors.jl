struct FuzzyVector
    numbers::Vector{FuzzyNumber}
end

Base.length(FV::FuzzyVector) = size(FV.numbers, 1)
Base.getindex(FV::FuzzyVector, i::Int64) = FV.numbers[i]
Base.show(io::IO, FV::FuzzyVector) = println(io, "fuzzy vector length $(length(FV))")

function Base.:∪(FV::FuzzyVector, vec::Vector{FuzzyNumber})
   append!(FV.numbers, vec)
   return FV
end

function draw(FV::FuzzyVector; fig=nothing, xlims=nothing, ylims=nothing, step=0.001, linecolor="black")
	if isnothing(fig)
		if isnothing(xlims) || isnothing(ylims)
			fig = plot(xlabel=L"x_1", ylabel=L"x_2", zlabel=L"\mu", zlims=(0, 1), dpi=600)
        else
			fig = plot(xlabel=L"x_1", ylabel=L"x_2", zlabel=L"\mu", xlims=xlims, ylims=ylims, zlims=(0, 1), dpi=600)
		end
	end
	if linecolor == "random"
		linecolor = rand(["black", "red", "blue", "green"])
	end

	A₁ = FV[1]
	A₂ = FV[2]
	X = collect(A₁.grades[1][1]:step:A₁.grades[1][2])
	Y = collect(A₂.grades[1][1]:step:A₂.grades[1][2])
	Z = [min(A₁[x], A₂[y]) for x in X, y in Y]
	surface!(fig, X, Y, Z, c=:jet1)
	# μ(x, y) = min(A₁[x], A₂[y])
	# surface!(fig, X, Y, μ, c=:jet1)
	
    # marking peak
	max_indices = argmax(Z)
	max_x = X[max_indices[1]]
	max_y = Y[max_indices[2]]
	μ = Z[max_indices]
	plot!(fig, annotation=[(max_x, max_y, μ)])
    # annotate!(fig, [(max_x, max_y, μ, (μ, 8, :black, :center))])

    current()
    return fig
end