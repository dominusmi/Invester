function MovingAverage(array::Array{<:AbstractFloat,1}, window::Integer)
	_range = collect(1.:window)
	return sum(array[end-window+1:end] .* _range) / sum(_range)
end
