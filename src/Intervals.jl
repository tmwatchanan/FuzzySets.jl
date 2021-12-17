import Base: +, -, *, /, ^, ==, ≈
import Base.abs

struct Interval
    left::Real
    right::Real

    function Interval(num1::Real, num2::Real)
        if num1 > num2
            error("Invalid interval, left must be less than right")
        end
        new(Float64(num1), Float64(num2))
    end

    function Interval(a::Real)
        new(Float64(a), Float64(a))
    end

    function Interval(a::Vector{<:Real})
        new(Float64(a[1]), Float64(a[2]))
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

Base.iterate(a::Interval) = a[1], 2
Base.iterate(a::Interval, state) = state > 2 ? nothing : (a[state], state+1)
Base.vec(a::Interval) = [a.left, a.right]

Base.:(==)(a::Interval, b::Interval) = a.left == b.left && a.right == b.right
Base.:≈(a::Interval, b::Interval) = a.left ≈ b.left && a.right ≈ b.right

Base.isempty(a::Interval) = isnan(a.left) || isnan(a.right)

Base.copy(a::Interval) = Interval(a.left, a.right)

mid(a::Interval) = (a.left + a.right) / 2
rad(a::Interval) = (a.right - a.left) / 2
mag(a::Interval) = max(abs(a.left), abs(a.right))
mig(a::Interval) = min(abs(a.left), abs(a.right))
abs(a::Interval) = Interval(mig(a), mag(a))
sqr(a::Interval) = a ^ 2

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

function Base.inv(a::Interval)
    left = a.right == 0 ? 0 : 1 / a.right
    right = a.left == 0 ? 0 : 1 / a.left
    # left = 1 / a.right
    # right = 1 / a.left
    # println(left, ",", right)
    Interval(left, right)
end
Base.:/(a::Real, b::Interval) = a * inv(b)
Base.:/(a::Interval, b::Interval) = a * (1 / b)

function Base.:^(a::Interval, b::Real)
    # println(a.left, ",", a.right)
    if b < 0
        a = 1 / a
        b = -b
    end

    if b == 0.5
        left = sqrt(a.left)
        right = sqrt(a.right)
    elseif b == 2
        if a.left <= 0 && 0 <= a.right
            left = 0
            right = mag(a)^2
        elseif a.left^2 <= a.right^2
            left = a.left ^ b
            right = a.right ^ b
        elseif a.right^2 <= a.left^2
            left = a.right ^ b
            right = a.left ^ b
        end
    else
        if a.left > 0 || isodd(b)
            left = a.left ^ b
            right = a.right ^ b
        elseif a.right < 0 && iseven(b)
            left = a.right ^ b
            right = a.left ^ b
        elseif a.left <= 0 && 0 <= a.right && iseven(b)
            left = 0
            # println(a.left)
            # println(abs(a.left))
            # println(max(abs(a.left), abs(a.right)))
            # println(mag(a))
            right = mag(a) ^ b
        end
    end
    left = left == Inf ? 0 : left
    right = right == Inf ? 0 : right
	Interval(left, right)
end

function Base.round(a::Interval; digits=2)
    Interval(round(a.left, digits=digits), round(a.right, digits=digits))
end