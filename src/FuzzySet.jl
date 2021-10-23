abstract type FuzzySet end

Base.length(A::FuzzySet) = length(A.grades)
Base.getindex(A::FuzzySet, lvl::Int64) = A.grades[lvl]
function (A::FuzzySet)(x)
    mfx = 0.0
    for l = length(A.grades):-1:1
        if A.grades[l].left ≤ x && x ≤ A.grades[l].right
            mfx = A.levels[l]
            break
        end
    end
    return mfx
end

cut(A::FuzzySet, α::Real) = A.grades[findfirst(x -> x == α, A.levels)]
support(A::FuzzySet) = A.grades[1]
core(A::FuzzySet) = A.grades[end]
function height(A::FuzzySet)
    for i = length(A.levels):-1:1
        level_cut = A.grades[i]
        if !isempty(level_cut)
            return A.levels[i]
        end
        return 0.0
    end
end
peak(A::FuzzySet) = mid(core(A))
