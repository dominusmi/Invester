using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames, Statistics
asset = Asset("QCOM")
history = LoadTop100History()

mean
hist = @from h in history[asset.symbol].history begin
	@where  h[:timestamp] >= Date(2018,6,1) &&
			h[:timestamp] <= Date(2019,6,25)
	@select (open = h[:open], adjusted_close = h[:adjusted_close],
		avg = mean([h[:open],h[:adjusted_close]]))
	@collect DataFrame
end

fig = plot(hist[:open], label="Open", xticks = 0:15:1000, legend=:topleft)
plot!(hist[:adjusted_close], label="Close")
plot!(hist[:avg], label="mean")
for days_interval in [2,7,30,60,180,360]
	mas = []
	iter = DayOfWeekIterator(Date(2018,6,1),260)
	for (i,day) in enumerate(iter)
		ma = DaysIntervalMA(asset, Day(days_interval), day)
		push!(mas, ma)
	end

	plot!(1:size(mas,1), mas[1:end], label="$days_interval", linestyle=:dot)
end
display(fig)


pf = Invester.MovingAveragePortfolio()
Juno.@enter Invester.SimulatePortfolioDecisionMaker(pf, Date(2019,1,1), Date(2019,1,10))


history = CheckLoadHistory()
assetHistory = @from h in history[:MSFT].history begin
	@where  h[:timestamp] >= Date(2019,6,1) - Day(720) &&
			h[:timestamp] <= Date(2019,6,1)
	@select (open = h[:open], adjusted_close = h[:adjusted_close],
		avg = mean([h[:open],h[:adjusted_close]]))
	@collect DataFrame
end
trends = zeros(0)

push!(trends, Invester.MovingAverageTrend(assetHistory[:avg], 7)[end])
push!(trends, Invester.MovingAverageTrend(assetHistory[:avg], 14)[end])
push!(trends, Invester.MovingAverageTrend(assetHistory[:avg], 30)[end])
push!(trends, Invester.MovingAverageTrend(assetHistory[:avg], 90)[end])
push!(trends, Invester.MovingAverageTrend(assetHistory[:avg], 365)[end])

# Check how many of the trends indicate future improvement
trends |>
t -> (t .> assetHistory[:avg][end]) |>
sum
