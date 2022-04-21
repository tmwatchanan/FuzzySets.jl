function u_fcm()
end

function c_fcm(memberships::Vector{<:Real}, patterns::Vector{<:Vector{<:Real}}; m::Real)
    N = length(patterns)
    d = length(patterns[1])

    numerator = zeros(d)
    denominator = 0.0
    for j = 1:N
        w = (memberships[j] ^ m)
        numerator += w * patterns[j]
        denominator += w
    end
    c = numerator / denominator
    c
end

function euclidean_distance(a, b; squared::Bool=false)
    d_squared = sum((a - b).^2)
    return squared ? d_squared : sqrt(d_squared)
end