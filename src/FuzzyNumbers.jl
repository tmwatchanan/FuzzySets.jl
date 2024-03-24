import Plots: current, plot, plot!, vline!, annotate!, scatter!, gr

mutable struct FuzzyNumber <: FuzzySet
    levels::Vector{<:Real}
    grades::Vector{Interval}

    function FuzzyNumber(levels::Vector{<:Real}, grades::Vector{Interval})
        A = new(levels, grades)
        # println("FuzzyNumber $(peak(A)) created")
        return A
    end

    # function FuzzyNumber(levels::Vector{<:Real}; number::Real=0.0, width::Real=0.5)
    #     println("Triangular FuzzyNumber $number created")
    #     new(levels, triangle.(levels, b=number, width=width))
    # end

    # function FuzzyNumber(levels::Vector{<:Real}; number::Real, w_l::Real, w_r::Real, a::Real)
    #     println("Trapezoidal FuzzyNumber $number created")
    #     new(levels, trapezoid.(levels, p=number, w_l=w_l, w_r=w_r, a=a))
    # end
end

function TriangularFuzzyNumber(levels::Vector{<:Real}; number::Real=0.0, width::Real=0.5)
    println("Triangular FuzzyNumber $number created")
    FuzzyNumber(levels, triangle.(levels, b=number, width=width))
end

function TrapezoidalFuzzyNumber(levels::Vector{<:Real}; number::Real, w_l::Real, w_r::Real, a::Real)
    println("Trapezoidal FuzzyNumber $number created")
    FuzzyNumber(levels, trapezoid.(levels, p=number, w_l=w_l, w_r=w_r, a=a))
end

function GaussianFuzzyNumber(levels::Vector{<:Real}; μ::Real, σ::Real)
    println("Gaussian FuzzyNumber $μ created")
    A = FuzzyNumber(levels, gaussian_interval.(levels; μ=μ, σ=σ))
    A.grades[1:80] .= [A.grades[81]] # solve infinite support
    A
end

function BoxFuzzyNumber(levels::Vector{<:Real}; a::Real, b::Real)
    println("BoxFuzzyNumber created")
    FuzzyNumber(levels, box.(levels, a=a, b=b))
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

function triangle(α::Real; b=0, width=0.5)
    (α >= 0 && α <= 1) || error("Invalid α")
    left(α, a, b) = (b - a) * α + a
    right(α, b, c) = c - (c - b) * α
    mfx(α, a, b, c) = Interval(left(α, a, b), right(α, b, c))
    return mfx(α, b - width, b, b + width)
end

function triangle(levels::Vector{<:Real}; b=0, width=0.5)
    return triangle.(levels, b=b, width=width)
end

function trapezoid(α::Real; p, w_l, w_r, a)
    (α >= 0 && α <= 1) || error("Invalid α")
    left(α, a, b) = (b - a) * α + a
    right(α, b, c) = c - (c - b) * α
    mfx(α, a, b, c, d) = Interval(left(α, a, b), right(α, c, d))
    return mfx(α, p - w_l - a, p - w_l, p + w_r, p + w_r + a)
end

function trapezoid(levels::Vector{<:Real}; p, w_l, w_r, a)
    return trapezoid.(levels, p=p, w_l=w_l, w_r=w_r, a=a)
end

function box(α::Real; a=0, b=1)
    (α >= 0 && α <= 1) || error("Invalid α")
    return Interval(a, b)
end

function box(levels::Vector{<:Real}; a=0, b=1)
    return box.(levels, a=a, b=b)
end

function SingletonFuzzyNumber(levels::Vector{<:Real}; number::Real=0.0)
    return FuzzyNumber(levels, repeat([Interval(number)], length(levels)))
end

function isSingleton(A::FuzzyNumber)
    if A[1].left != A[1].right
        return false
    end
    B = SingletonFuzzyNumber(A.levels, number=A[1].left)
    return A == B
end

function gaussian_interval(y::Real; μ::Real, σ::Real)
    term = sqrt(-2 * σ^2 * log(y))
    Interval(μ - term, μ + term)
end

function draw(fuzzynumber::FuzzyNumber; fig=nothing, range=nothing, linecolor="black", font=Plots.font("Times", 8), ylabel="", dpi=200)
    # gr(xguidefont=font, yguidefont=font, xtickfont=font, ytickfont=font, legendfont=font)
	if isnothing(fig)
		if isnothing(range)
            fig = plot(ylabel=ylabel, ylims = (0, 1))
        else
			xmin = range[1]
			xmax = range[2]
            fig = plot(ylabel=ylabel, xlims = (xmin, xmax), ylims = (0, 1)) # xticks=collect(xmin:1:xmax)
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
    annotate!(fig, [(xₘ, μ, (round(xₘ, digits=2), 8, :blue, :left))])
    # vline!(fig, [xₘ], line=(:dot), linecolor=:black, legend=false)
    if isSingleton(fuzzynumber)
        annotate!(fig, [(0.4, 0.5, ("singleton", 8, :black, :left))])
    end
    plot!(dpi=dpi)

    current()
    return fig
end

function draw_u(fuzzynumbers::Vector{FuzzyNumber}; fig=nothing, range=nothing, linecolors::Vector{String}=["black", "red"], xlabel="", ylabel="", font=Plots.font("Times", 8), size=(450, 150), offset_value=0)
    gr(xguidefont=font, xtickfont=font, ytickfont=font, ztickfont=font, legendfont=font)
	if isnothing(fig)
		if isnothing(range)
            fig = plot(ylims = (0, 1))
        else
			xmin = range[1]
			xmax = range[2]
            fig = plot(xlims = (xmin, xmax), ylims = (0, 1), xticks=collect(xmin:0.2:xmax))
		end
	end

    for (index, (fuzzynumber, linecolor)) in enumerate(zip(fuzzynumbers, linecolors))
        # draw level cuts
        if isSingleton(fuzzynumber)
            println("SINGLETON!")
            vline!(fig, [fuzzynumber[1].left], linecolor=linecolor, legend=false, xlabel=xlabel, ylabel=ylabel)
        end
        for i = 1:length(fuzzynumber.levels)
            lvl = fuzzynumber.levels[i]
            interval = fuzzynumber[i]
            if interval.left == interval.right
                # scatter!(fig, [interval.left], [lvl], c=linecolor, marker=1, markershape=:cross, legend=false, xlabel=xlabel, ylabel=ylabel)
            else
                plot!(fig, vec(interval), [lvl, lvl], linecolor=linecolor, legend=false, seriesalpha=0.2)
            end
            # break
        end
        
        # points = [Point2f0(fuzzynumber.grades[i][1], fuzzynumber.levels[i]) => Point2f0(fuzzynumber.grades[i][2], fuzzynumber.levels[i]) for i = 1:length(fuzzynumber.levels)]
        # linesegments(points, color = :red, linewidth = 2)

        # marking peak
        xₘ = peak(fuzzynumber)
        μ = fuzzynumber(xₘ)
        peak_text = string(round(xₘ, digits=2))
        if isSingleton(fuzzynumber)
            # peak_text *= " [s]"
        end
        # if xₘ == 1.0
        #     xₘ -= 0.1
        # end
        offset = -(index - 1) * offset_value
        position = index == 1 ? :left : :right
        annotate!(fig, [(xₘ, μ+offset, (peak_text, 8, linecolor, position, "Times"))])
        # vline!(fig, [xₘ], line=(:dot), linecolor=:black, legend=false)
    end
    plot!(dpi=600, size=size, xlabel=xlabel, ylabel=ylabel)

    current()
    return fig
end


# FUZZY ARITHMETIC ============================================================

Base.:-(A::FuzzyNumber) = FuzzyNumber(A.levels, (-).(A.grades))
Base.:^(A::FuzzyNumber, exponent::Real) = FuzzyNumber(A.levels, A.grades .^ exponent)

Base.:+(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (+).(A.grades, B.grades))
Base.:-(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (-).(A.grades, B.grades))
Base.:*(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (*).(A.grades, B.grades))
Base.:/(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (/).(A.grades, B.grades))
Base.:*(a::Real, B::FuzzyNumber) = SingletonFuzzyNumber(B.levels, number=a) * B
Base.:/(a::Real, B::FuzzyNumber) = SingletonFuzzyNumber(B.levels, number=a) / B
Base.:*(A::FuzzyNumber, a::Real) = a * A

# =============================================================================

function cut(X::Vector{FuzzyNumber}, α::Real)
	N = length(X)
	cuts = [cut(X[i], α) for i = 1:N]
    cuts
end