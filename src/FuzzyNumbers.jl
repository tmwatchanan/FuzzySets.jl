import Plots: current, plot, plot!, vline!, annotate!, scatter!

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

Base.show(io::IO, A::FuzzyNumber) = println(io, "fuzzy number peak $(peak(A))")
Base.copy(A::FuzzyNumber) = FuzzyNumber(copy(A.levels), copy(A.grades))

function Base.:(==)(A::FuzzyNumber, B::FuzzyNumber)
    if A.levels != B.levels
        return false
    end
    for lvl = 1:length(A.levels)
        if A[lvl] != B[lvl]
            return false
        end
    end
    return true
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

function SingletonFuzzyNumber(levels::Vector{Float64}; number::Real=0.0)
    return FuzzyNumber(levels, repeat([Interval(number)], length(levels)))
end

function isSingleton(A::FuzzyNumber)
    if A[1].left != A[1].right
        return false
    end
    B = SingletonFuzzyNumber(A.levels, number=A[1].left)
    return A == B
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
        interval = fuzzynumber[i]
        if interval.left == interval.right
            scatter!(fig, [interval.left], [lvl], c=linecolor, marker=1, legend=false)
        else
            plot!(fig, vec(interval), [lvl, lvl], linecolor=linecolor, legend=false)
        end
        # break
	end
    # points = [Point2f0(fuzzynumber.grades[i][1], fuzzynumber.levels[i]) => Point2f0(fuzzynumber.grades[i][2], fuzzynumber.levels[i]) for i = 1:length(fuzzynumber.levels)]
    # linesegments(points, color = :red, linewidth = 2)

    # marking peak
    xₘ = peak(fuzzynumber)
    μ = fuzzynumber(xₘ)
    annotate!(fig, [(xₘ, μ, (round(xₘ, digits=2), 8, :black, :left))])
    # vline!(fig, [xₘ], line=(:dot), linecolor=:black, legend=false)

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

# =============================================================================

function clip(A::FuzzyNumber, α::Real=0.2)
    B = copy(A)
    clip!(B, α)
end

function clip!(A::FuzzyNumber; α::Real=0.2)
	_lvl = Int(floor(length(A.levels) / (1 / α)))
	for lvl = 1:_lvl
		A.grades[lvl] = A.grades[_lvl + 1]
	end
end

function dampen_slope!(A::FuzzyNumber; multiplier::Real=0.8)
    if isSingleton(A)
        return
    end
    x3 = support(A).right
    x2 = peak(A)
    x1 = support(A).left
    y3 = A(x3)
    y2 = A(x2)
    y1 = A(x1)
    left_slope = (y2 - y1) / (x2 - x1)
    right_slope = (y3 - y2) / (x3 - x2)
    left_slope /= multiplier
    right_slope /= multiplier
    left_intercept = y2 - (left_slope * x2)
    right_intercept = y2 - (right_slope * x2)
    for lvl = 1:length(A.levels)
        y = A.levels[lvl]
        # x = (y - b) / m
        left = (y - left_intercept) / left_slope
        right = (y - right_intercept) / right_slope
        left = min(left, x2)
        right = max(x2, right)
		A.grades[lvl] = Interval(left, right)
	end
end

function clip(A::FuzzyNumber, left::Real, right::Real)
    B = copy(A)
	for lvl = 1:length(B.levels)
        _left = B.grades[lvl].left
        _right = B.grades[lvl].right
        if (!isnothing(left) && _left < left) _left = left end
        if (!isnothing(right) && _right < right) _right = right end
		B.grades[lvl] = Interval(_left, _right)
	end
	B
end

function cut(X::Vector{FuzzyNumber}, α::Real)
	N = length(X)
	cuts = [cut(X[i], α) for i = 1:N]
    cuts
end