using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames, Statistics

pf = Invester.MovingAveragePortfolio(upperClosePercentageThreshold=10,
	maxInvestments = 20)
Invester.SimulatePortfolioDecisionMaker(pf, Date(2019,1,1), Date(2019,2,1))
Invester.PotentialProfit(pf, Date(2019,2,11))
ClosedProfit(pf)
size(pf.investments)

asset = Asset("QCOM")
history = LoadTop100History()

mean
hist = @from h in history[:FOXA].history begin
	@where  h[:timestamp] >= Date(2019,1,2) &&
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

size(OpenInvestments(pf),1)
Invester.MaxNumberOfInvestment(pf)
size(OpenInvestments(pf),1) < Invester.MaxNumberOfInvestment(pf)
