using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames

pf = Invester.MovingAveragePortfolio(upperClosePercentageThreshold=10,
	lowerClosePercentageThreshold=-0.1,
	maxInvestments = 20)
Invester.SimulatePortfolioDecisionMaker(pf, Date(2019,1,1), Date(2019,3,15))
Invester.PotentialProfit(pf, Date(2019,2,11))
ClosedProfit(pf)

function test(pf)
	startDate = Date(pf.investments[1].dateOpen)
	openInvs = OpenInvestments(pf)
	closedInvs = ClosedInvestments(pf)
	endDate = Date(max(openInvs[end].dateOpen, closedInvs[end].dateClosed))

	potProfits = []
	closedProfits = []


	# Re-create history from investment log
	wsdi = Invester.WallStreetDayIterator(startDate+Day(1),endDate)
	for date in wsdi
		# Fetch all investments which were open and not yet closed
	    toFetchOpen = [x for x in Invester.Select(x->x.dateOpen <= date, openInvs)]
	    toFetchClosed = [x for x in Invester.Select(x->x.dateOpen <= date && x.dateClosed > date, closedInvs)]
	    invsToFetch = vcat(toFetchOpen, toFetchClosed)

		# Fetch price on historic day
		## Not too sure about this code, why not simply call FetchCloseAssetValue in loop directly?
		assets = map(x->x.asset, invsToFetch)
		marketCloseValuesOnDate = Invester.FetchCloseAssetValue.(assets,date)
		asset2MarketPrice = Dict()
		for i in 1:size(marketCloseValuesOnDate,1)
			asset2MarketPrice[assets[i]] = marketCloseValuesOnDate[i]
		end

		dayPotProfits = [ PotentialProfit(inv, asset2MarketPrice[inv.asset]) for inv in InvestmentsOpenOn(pf,date)]
		push!(potProfits, sum(dayPotProfits))

		closedAtDate = Invester.Select(x->x.dateClosed <= date, ClosedInvestments(pf))
		push!(closedProfits, sum(ClosedProfit.(closedAtDate)))

		println("On $date:")
		println("Current potential profit: $dayPotProfits")
		println("\tClosed today:")
		for cad in InvestmentsClosedOn(pf,date)
			println("\t\t$(cad.asset): $(cad.dateOpen) => $(cad.valueOpen) - $(cad.valueClose) = $(cad.closedReturn.value)")
			println("\t\tClosed profit up to now: $(closedProfits[end])")
		end
		println("\tOpened today:")
		for cad in InvestmentsOpenedOn(pf,date)
			if typeof(cad) <: Investment
				println("\t\t$(Asset(cad)): $(DateOpen(cad)) => $(ValueOpen(cad))")
			elseif typeof(cad) <: ClosedInvestment
				println("\t\t$(Asset(cad)): $(DateOpen(cad)) => $(ValueOpen(cad))")
			end
		end
	end
	closedProfits

	plot(potProfits, label="Potential Profit", xticks=0:3:100)
	plot!(closedProfits, label="Closed Profit")
end

test(pf)
sum([ PotentialProfit(inv, Invester.FetchCloseAssetValue(inv.asset, Date(2019,6,28))) for inv in OpenInvestments(pf)])

date = Date(2019,1,11)
invs = InvestmentsOpenOn(pf,date)
Invester.FetchCloseAssetsValueDictionary([inv.asset for inv in invs], date)
dayPotProfits = [ PotentialProfit(inv, asset2MarketPrice[inv.asset]) for inv in InvestmentsOpenOn(pf,date)]

date = Date(2019,1,4)
toFetchClosed = [x.asset for x in Invester.Select(x->x.dateOpen < date && x.dateClosed > date, closedInvs)]


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
