using Invester
using Invester: LogJobInfo, LogJobError
using Plots
using Dates, Query, JuliaDB, DataFrames
using Statistics
using MySQL

Invester.CheckLoadHistory()

# Update long running portfolio
LogJobInfo("--------------------------------------------")
LogJobInfo("Running daily recommendations Moving Average")
pf = Invester.LoadPortfolio("dailyMovingAverage")
Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today())
Invester.SavePortfolio(pf, "dailyMovingAverage")
LogJobInfo("Succesfully terminated daily recommendations Moving Average")
