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
function centroid(A::FuzzySet; step::Float64=0.01)
    c = 0.0
    μ = 0.0
    for x = support(A).left:step:support(A).right
        c += x * A(x)
        μ += A(x)
    end
    c / μ
end

peak_center(A::FuzzySet) = sum(A.grades[end]) / 2

function specificity(A::FuzzySet)
    sp = 0
	for (lvl, α) in enumerate(A.levels)
		A_cut = cut(A, α)
		sp += 1 - (A_cut.right - A_cut.left)
	end
	sp / length(A.levels)
end

function u_uncertainty(A::FuzzySet)
    if isSingleton(A)
        return 0
    end
    u = 0
    alphas = [reverse(A.levels); 0]
	for j = 1:length(A.levels)
        α_current = alphas[j]
        α_below = alphas[j + 1]
		A_cut = cut(A, α_current)
        if isnan(A_cut.left)
            continue
        end
		u += (α_current - α_below) * log(1 + width(A_cut))
	end
	u / height(A)
end
