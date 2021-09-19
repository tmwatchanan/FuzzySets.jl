abstract type FuzzySet end

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
