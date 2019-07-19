const OneWeek = Dates.Day(7)
const ThreeWeeks = Dates.Day(21)
const OneMonth = Dates.Day(30)
const ThreeMonths = Dates.Day(90)
const SixMonths = Dates.Day(180)
const OneYear = Dates.Day(365)
const TwoYears = Dates.Day(730)

""" Calculates the instantaneous moving average """
function MovingAverage(array::Array{<:AbstractFloat,1}, window::Integer; offset::Integer = 0)
	_range = collect(1.:window)
	start = size(array,1) - window + 1 - offset
	finish = size(array,1) - offset
	return sum(array[start:finish] .* _range) / sum(_range)
end

""" Calculates the trend of the moving average """
function MovingAverageTrend(array::Array{<:AbstractFloat,1}, window::Integer; offset=0)
	interval = size(array,1) - offset
	interval <= window ? throw("Window must be smaller than array size: interval $interval, window $window") : nothing

	trend = zeros(0)

	for i in 1:interval-window
		push!(trend, MovingAverage(array[i:i+window], window))
	end
	trend
end


# Expects x, y to be exactly 3 in length
∂(x,y) = (y[3] - y[1]) / (x[3] - x[1])


function SixMonthsMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - SixMonths, yesterday)
	MovingAverage(array, size(array,1))
end

function ThreeMonthsMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - ThreeMonths, yesterday)
	MovingAverage(array, size(array,1))
end

function OneMonthMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - OneMonth, yesterday)
	MovingAverage(array, size(array,1))
end

function ThreeWeeksMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - ThreeWeeks, yesterday)
	MovingAverage(array, size(array,1))
end

function OneWeekMA(asset::Asset, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - OneWeek, yesterday)
	MovingAverage(array, size(array,1))
end

function DaysIntervalMA(asset::Asset, interval::Dates.Day, today::GenericDate = Dates.Today)
	yesterday = Date(today) - Dates.Day(1)
	array = FetchAverageAssetValue(asset, yesterday - interval, yesterday)
	MovingAverage(array, size(array,1))
end
