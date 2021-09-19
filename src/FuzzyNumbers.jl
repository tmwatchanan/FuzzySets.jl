import Plots: current, plot, plot!, vline!, annotate!

mutable struct FuzzyNumber <: FuzzySet
    levels::Vector{Float64}
    grades::Vector{Interval}

    function FuzzyNumber(levels::Vector{Float64}, grades::Vector{Interval})
        A = new(levels, grades)
        println("FuzzyNumber $(peak(A)) created")
        return A
    end

    function FuzzyNumber(levels::Vector{Float64}; number::Real=0.0, width::Real=0.5)
        println("FuzzyNumber $number created")
        new(levels, triangle.(levels, b=number, width=width))
    end
end

Base.length(A::FuzzyNumber) = length(A.grades)
Base.getindex(A::FuzzyNumber, lvl::Int64) = A.grades[lvl]
function (A::FuzzyNumber)(x)
    mfx = 0.0
    for l = length(A.grades):-1:1
        if A.grades[l][1] ≤ x && x ≤ A.grades[l][2]
            mfx = A.levels[l]
            break
        end
    end
    return mfx
end

function triangle(x::Real; b=0, width=0.5)
    left(α, a, b) = (b - a) * α + a
    right(α, b, c) = c - (c - b) * α
    mfx(α, a, b, c) = Interval(left(α, a, b), right(α, b, c))
    return mfx(x, b - width, b, b + width)
end

function triangle(levels::Vector{Float64}; b=0, width=0.5)
    return triangle.(levels, b=b, width=width)
end

function draw(fuzzynumber::FuzzyNumber; fig=nothing, range=nothing, linecolor="black")
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

    # draw level cuts
	for i = 1:length(fuzzynumber.levels)
		lvl = fuzzynumber.levels[i]
		plot!(fig, vec(fuzzynumber[i]), [lvl, lvl], linecolor=linecolor, legend=false)
	end
    # points = [Point2f0(fuzzynumber.grades[i][1], fuzzynumber.levels[i]) => Point2f0(fuzzynumber.grades[i][2], fuzzynumber.levels[i]) for i = 1:length(fuzzynumber.levels)]
    # linesegments(points, color = :red, linewidth = 2)

    # marking peak
    xₘ = peak(fuzzynumber)
    vline!(fig, [xₘ], line=(:dot), linecolor=:black, legend=false)
    μ = fuzzynumber(xₘ)
    annotate!(fig, [(xₘ, μ, (μ, 8, :black, :left))])
    current()
    return fig
end


# FUZZY ARITHMETIC ============================================================

Base.:+(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (+).(A.grades, B.grades))
Base.:-(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (-).(A.grades, B.grades))
Base.:*(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (*).(A.grades, B.grades))
Base.:/(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (/).(A.grades, B.grades))
Base.:*(a::Real, A::FuzzyNumber) = FuzzyNumber(A.levels, (*).(a, A.grades))
Base.:*(A::FuzzyNumber, a::Real) = a * A
