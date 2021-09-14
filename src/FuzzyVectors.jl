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

function draw(FV::FuzzyVector; fig=nothing, range=nothing, linecolor="black")
	if isnothing(fig)
		if isnothing(range)
            fig = plot(ylims = (0, 1), dpi=600)
        else
			xmin = range[1]
			xmax = range[2]
            fig = plot(xlims = (xmin, xmax), ylims = (0, 1), xticks=collect(xmin:1:xmax), dpi=600)
		end
	end
	if linecolor == "random"
		linecolor = rand(["black", "red", "blue", "green"])
	end
	for i = 1:length(fuzzynumber.levels)
		lvl = fuzzynumber.levels[i]
		plot!(fig, fuzzynumber.grades[i, :], [lvl, lvl], linecolor=linecolor, legend=false)
	end
    current()
    return fig
end