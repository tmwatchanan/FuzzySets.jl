abstract type FuzzySet end

mutable struct FuzzyNumber <: FuzzySet
    levels::Vector{Float64}
    grades::Vector{Vector{Float64}}


    function FuzzyNumber(levels::Vector{Float64}, grades::Vector{Vector{Float64}})
        peak = maximum(maximum(grades))
        println("FuzzyNumber $peak created")
        return new(levels, grades)
    end

    function FuzzyNumber(levels::Vector{Float64}; number::Number=0.0, width::Number=0.5)
        println("FuzzyNumber $number created")
        return new(levels, triangle.(levels, b=number, width=width))
    end
end

Base.getindex(A::FuzzyNumber, i::Int64) = A.grades[i]
Base.length(A::FuzzyNumber) = length(A.grades)

function triangle(x::Float64; b=0, width=0.5)
    left(α, a, b) = (b - a) * α + a
    right(α, b, c) = c - (c - b) * α
    mfx(α, a, b, c) = [left(α, a, b), right(α, b, c)]
    return mfx(x, b - width, b, b + width)
end

function triangle(levels::Vector{Float64}; b=0, width=0.5)
    return triangle.(levels, b=b, width=width)
end

function draw(fuzzynumber::FuzzyNumber; fig=nothing, range=nothing, linecolor="black")
    println("fuzzy number ", maximum(maximum(fuzzynumber.grades)))
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