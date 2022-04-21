function vertical_cut(A::FuzzyNumber; α::Real=0.2)
    B = copy(A)
    vertical_cut!(B, α=α)
    B
end

function vertical_cut!(A::FuzzyNumber; α::Real=0.2)
	_lvl = Int(floor(length(A.levels) / (1 / α)))
	for lvl = 1:_lvl
		A.grades[lvl] = A.grades[_lvl + 1]
	end
end

function vertical_cut(A::FuzzyNumber, left::Real, right::Real)
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

function linearly_dampen(A::FuzzyNumber; multiplier::Real=0.5)
    if isSingleton(A)
        return A
    end
    B = copy(A)
    FuzzySets.linearly_dampen!(B, multiplier=multiplier)
    B
end

function linearly_dampen!(A::FuzzyNumber; multiplier::Real=0.5)
    if isSingleton(A)
        return
    end
    x3 = support(A).right
    x2 = peak(A)
    x1 = support(A).left
    y3 = A(x3)
    y2 = A(x2)
    y1 = A(x1)
    bound_0 = (x2 - x1 == 0) ? true : false
    bound_1 = (x3 - x2 == 0) ? true : false
    left_slope = (y2 - y1) / (x2 - x1)
    right_slope = (y3 - y2) / (x3 - x2)
    left_slope /= multiplier
    right_slope /= multiplier
    left_intercept = y2 - (left_slope * x2)
    right_intercept = y2 - (right_slope * x2)
    for (lvl, α) in enumerate(A.levels)
        # x = (y - b) / m
        left = (α - left_intercept) / left_slope
        right = (α - right_intercept) / right_slope
        left = bound_0 ? 0 : left
        right = bound_1 ? 1 : right
        left = min(left, x2)
        right = max(x2, right)
		A.grades[lvl] = Interval(left, right)
	end
end

function reflection_dampen(A::FuzzyNumber)
    B = copy(A)
    reflection_dampen!(B)
    B
end

function reflection_dampen!(A::FuzzyNumber)
    if isSingleton(A)
        return
    end
    x3 = support(A).right
    x2 = peak(A)
    x1 = support(A).left

    bound_0 = (x2 - x1 == 0) ? true : false
    bound_1 = (x3 - x2 == 0) ? true : false

    is_left_narrower =  x2 - x1 < x3 - x2
    for lvl = 1:length(A.levels)
        if is_left_narrower
            left = A.grades[lvl].left
            right = x2 + (x2 - left)
        else
            right = A.grades[lvl].right
            left = x2 - (right - x2)
        end
        # left = bound_0 ? 0 : left
        # right = bound_1 ? 1 : right
        left = min(left, x2)
        right = max(x2, right)
		A.grades[lvl] = Interval(left, right)
	end
end

function midpoint_dampen(A::FuzzyNumber)
    B = copy(A)
    midpoint_dampen!(B)
    B
end

function midpoint_dampen!(A::FuzzyNumber; δ::Float64=0.5)
    if isSingleton(A)
        return
    end

    peak_mid = peak(A)
    for lvl = 1:length(A.levels)
        cut = A.grades[lvl]
        midpoint = mid(cut)
        # is_left_narrower =  midpoint - cut.left < cut.right - midpoint
        # if is_left_narrower
        #     midpoint = 
        # else
        # end
        Δleft = midpoint - cut.left
        Δright = cut.right - midpoint
        left = peak_mid - (Δleft * δ)
        right = peak_mid + (Δright * δ)
        left = max(min(left, peak_mid), 0)
        right = min(max(peak_mid, right), 1)
		A.grades[lvl] = Interval(left, right)
	end
end
