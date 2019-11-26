const OneWeek = Dates.Day(7)
const ThreeWeeks = Dates.Day(21)
const OneMonth = Dates.Day(30)
const ThreeMonths = Dates.Day(90)
const SixMonths = Dates.Day(180)
const OneYear = Dates.Day(365)
const TwoYears = Dates.Day(730)

""" Calculates the instantaneous moving average = ∑xᵢ⋅i / ∑i"""
function InstantaneousMovingAverage(array::AbstractArray{<:Number,1}, window::Integer; offset::Integer = 0)
	_range = collect(1.:window)
	# Since moving average is taken w.r.t. last number of array (-offset),
	# need to find start index
	start = size(array,1) - window + 1 - offset
	finish = size(array,1) - offset
	return sum(array[start:finish] .* _range) / sum(_range)
end

""" Calculates the moving average of an array"""
function MovingAverage(array::AbstractArray{<:Number,1}, window::Integer; offset=0)
	interval = size(array,1) - offset
	interval <= window ? throw("Window must be smaller than array size: interval $interval, window $window") : nothing

	trend = zeros(0)

	for i in 1:interval-window
		push!(trend, InstantaneousMovingAverage(array[i:i+window], window))
	end
	trend
end

""" Calculates the coefficient for the ridge linear regression of an array"""
function LinearTrend(array::AbstractArray{<:Number,1}, λ::Number=0.001)
	o = fit!(LinRegBuilder(), zip(1:size(array,1), array .- array[1]))
	weights = coef(o, λ, y=2, x=[1], bias=false)

	weights[1]
end

""" Calculates the trend over all the windows of a one-dimensional array """
function MovingLinearTrend(array::AbstractArray{<:Number,1}, window::Integer)
	lreg_coef = zeros(size(array,1)-window+1)
	for (i,_) in enumerate( (window):size(array,1) )
	    subArray = view(array, i:(i+window-1))
	    lreg_coef[i] = LinearTrend(subArray)
	end
	lreg_coef
end


# Expects x, y to be exactly 3 in length
∂(x,y) = (y[3] - y[1]) / (x[3] - x[1])


function SixMonthsMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - SixMonths, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end

function ThreeMonthsMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - ThreeMonths, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end

function OneMonthMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - OneMonth, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end

function ThreeWeeksMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - ThreeWeeks, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end

function OneWeekMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - OneWeek, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end

function DaysIntervalMA(asset::Asset, interval::Dates.Day, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - interval, yesterday)
	InstantaneousMovingAverage(array, size(array,1))
end
