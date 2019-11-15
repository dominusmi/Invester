using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames
using Statistics
using MySQL

pf = Invester.MovingAveragePortfolio(upperClosePercentageThreshold=5,
	lowerClosePercentageThreshold=-10,
	maxInvestments = 10)

Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today())

pf.investments

# Save investments
for _inv in pf.investments
	SaveInvestment(_inv)
end

"""INSERT INTO Investments (asset, value, dateOpen, uuid, type, invested)
		VALUES ('$(_inv.asset.symbol)', $(_inv.value), '$(Dates.format(_inv.dateOpen, "dd/mm/yyyy HH:MM:SS"))',
		'$(_inv.uuid)', 'Long', $(_inv.invested));"""
