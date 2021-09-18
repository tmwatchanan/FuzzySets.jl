function d(A⃗::FuzzyVector, B⃗::FuzzyVector)
    for (A, B) in zip(A⃗, B⃗)
        println(A, B)
    end
end

function d()
	xx = []
	ww = []
	A₁ = X⃗.numbers[1]
	A₂ = X⃗.numbers[2]
	W₁ = W⃗.numbers[1]
	W₂ = W⃗.numbers[2]
	for i = 1:length(A₁)
		push!(xx, [A₁.grades[i], A₂.grades[i]])
		push!(ww, [W₁.grades[i], W₂.grades[i]])
	end

function d(a::Vector{Float64}, b::Vector{Float64})

end