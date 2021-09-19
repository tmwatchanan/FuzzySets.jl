import Base: +, -, *, /, ^, ==, ≈

struct Interval
    left::Real
    right::Real

    function Interval(num1::Real, num2::Real)
        return new(Float64(num1), Float64(num2))
    end

    function Interval(a::Real)
        return new(Float64(a), Float64(a))
    end

    function Interval(a::Vector{<:Real})
        return new(Float64(a[1]), Float64(a[2]))
    end

    function Interval()
        new(NaN, NaN)
    end
end

function ..(a::Real, b::Real)
    Interval(a, b)
end

function Base.getindex(a::Interval, index::Int64)
    if index == 1 return a.left
    elseif index == 2 return a.right
    else return nothing
    end
end

Base.iterate(a::Interval, state=1) = state > 2 ? nothing : (a[state], state+1)
Base.vec(a::Interval) = [a.left, a.right]

Base.:(==)(a::Interval, b::Interval) = a.left == b.left && a.right == b.right
Base.:≈(a::Interval, b::Interval) = a.left ≈ b.left && a.right ≈ b.right

Base.isempty(a::Interval) = isnan(a.left) || isnan(a.right)

mid(a::Interval) = (a.left + a.right) / 2
rad(a::Interval) = (a.left - a.right) / 2


# INTERVAL ARITHMETIC ========================================================

Base.:+(a::Interval, b::Interval) = Interval(a.left + b.left, a.right + b.right)
Base.:-(a::Interval, b::Interval) = Interval(a.left - b.right, a.right - b.left)

function Base.:*(a::Interval, b::Interval)
    m1 = a.left * b.left
    m2 = a.left * b.right
    m3 = a.right * b.left
    m4 = a.right * b.right
    left = min(m1, m2, m3, m4)
    right = max(m1, m2, m3, m4)
	Interval(left, right)
end

function Base.:*(a::Real, b::Interval)
    left = a * b.left
    right = a * b.right
    if a < 0
        left, right = right, left
    end
	Interval(left, right)
end
Base.:*(a::Interval, b::Real) = b * a

Base.:/(a::Interval, b::Interval) = a * Interval(1 / b.left, 1 / b.right)

function Base.:^(a::Interval, b::Real)
    if b == 2
        if a.left a.right
            left = 0
            right = a.left == 0 ? a.right^2 : a.left^2
        elseif a.left^2 <= a.right^2
            left = a.left ^ b
            right = a.right ^ b
        elseif a.right^2 <= a.left^2
            left = a.right ^ b
            right = a.left ^ b
        end
    end
	Interval(left, right)
end