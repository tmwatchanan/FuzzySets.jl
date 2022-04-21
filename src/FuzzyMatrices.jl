struct FuzzyMatrix
    numbers::Matrix{FuzzyNumber}
end

function zeros(levels::Vector{<:Real}, dim1::Int64, dim2::Int64)
    M = Matrix{FuzzyNumber}(undef, dim1, dim2)
    Z = SingletonFuzzyNumber(levels, number=0)
    for i = 1:dim1
        for j = 1:dim2
            M[i, j] = Z
        end
    end
    M
end