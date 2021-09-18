import Base: +, -, *, /, ^

struct Interval
    left::Float64
    right::Float64

    function Interval(a::Vector{Float64})
        return new(a[1], a[2])
    end
end

Base.:+(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (+).(A.grades, B.grades))
Base.:-(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (-).(A.grades, B.grades))
Base.:*(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (*).(A.grades, B.grades))
Base.:/(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (/).(A.grades, B.grades))
Base.:*(a::Number, A::FuzzyNumber) = FuzzyNumber(A.levels, (*).(a, A.grades))
Base.:*(A::FuzzyNumber, a::Number) = a * A

function Base.:+(a::Vector{Float64}, b::Vector{Float64})
    left = a[1] - b[2]
    right = a[2] - b[1]
	return [left, right]
end

function Base.:-(a::Vector{Float64}, b::Vector{Float64})
    left = a[1] - b[2]
    right = a[2] - b[1]
	return [left, right]
end

function Base.:*(a::Vector{Float64}, b::Vector{Float64})
    m1 = a[1] * b[1]
    m2 = a[1] * b[2]
    m3 = a[2] * b[1]
    m4 = a[2] * b[2]
    left = min(m1, m2, m3, m4)
    right = max(m1, m2, m3, m4)
	return [left, right]
end

function Base.:/(a::Vector{Float64}, b::Vector{Float64})
    left, right = a * [1 / b[1], 1 / b[2]]
	return [left, right]
end

function Base.:*(a::Number, b::Vector{Float64})
    left = a * b[1]
    right = a * b[2]
    if a < 0
        left, right = right, left
    end
	return [left, right]
end
Base.:*(a::Vector{Float64}, b::Number) = b * a

function Base.:^(a::Vector{Float64}, b::Number)
    if b == 2
        if a[1] == 0 || a[2] == 0
            left = 0
            right = a[1] == 0 ? a[2]^2 : a[1]^2
        else if a[1]^2 <= a[2]^2
            left = a[1] ^ b
            right = a[2] ^ b
        elseif a[2]^2 <= a[1]^2
            left = a[2] ^ b
            right = a[1] ^ b
        end
    end
	return [left, right]
end
