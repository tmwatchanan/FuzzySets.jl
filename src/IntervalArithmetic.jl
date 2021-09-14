import Base: +, -, *, /, ^

Base.:+(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (+).(A.grades, B.grades))
Base.:-(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (-).(A.grades, B.grades))
Base.:*(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (*).(A.grades, B.grades))
Base.:/(A::FuzzyNumber, B::FuzzyNumber) = FuzzyNumber(A.levels, (/).(A.grades, B.grades))
Base.:*(a::FuzzyNumber, A::FuzzyNumber) = FuzzyNumber(A.levels, (*).(a, A.grades))
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

function Base.:^(a::Vector{Float64}, b::Vector{Float64})
    # if iseven(b)
        left = a[1] ^ b
        right = a[2] ^ b
    # end
	return [left, right]
end