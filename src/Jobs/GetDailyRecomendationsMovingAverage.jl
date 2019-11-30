using Invester
using Invester: LogJobInfo, LogJobError
using Plots
using Dates, Query, JuliaDB, DataFrames
using Statistics
using MySQL
using Flux
using CuArrays
using Tracker
using BSON

Invester.CheckLoadHistory()

# Update daily recommendations
# LogJobInfo("--------------------------------------------")
# LogJobInfo("Running daily recommendations Moving Average")
# pf = Invester.LoadPortfolio("dailyRecommendation")
# deleteat!(pf.investments, 1:size(pf.investments,1))
# Invester.DeletePortfolioInvestments("dailyRecommendation")
# Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today(), dayIterator=Invester.DayIterator)
# Invester.SavePortfolio(pf, "dailyRecommendation")
# LogJobInfo("Succesfully terminated daily recommendations Moving Average")
#
# # Update long running portfolio
# LogJobInfo("--------------------------------------------")
# LogJobInfo("Running historical Moving Average")
# pf = Invester.LoadPortfolio("dailyMovingAverage")
# Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today(), dayIterator=Invester.DayIterator)
# Invester.SavePortfolio(pf, "dailyMovingAverage")
# LogJobInfo("Succesfully terminated daily historical Moving Average")
#
#
# LogJobInfo("--------------------------------------------")
# LogJobInfo("Running historical Moving Average with Trend")
# pf = Invester.LoadPortfolio("dailyMovingAverageTrend")
# Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today(), dayIterator=Invester.DayIterator)
# Invester.SavePortfolio(pf, "dailyMovingAverageTrend")
# LogJobInfo("Succesfully terminated daily historical Moving Average")

LogJobInfo("--------------------------------------------")
LogJobInfo("Running Financial Metrics CNN portfolio")
pf = Invester.LoadPortfolio("dailyFMCNN")
Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today(), dayIterator=Invester.DayIterator)
Invester.SavePortfolio(pf, "dailyFMCNN")
LogJobInfo("Succesfully terminated daily Financial Metrics CNN portfolio")
