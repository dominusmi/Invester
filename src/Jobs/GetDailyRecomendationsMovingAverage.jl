using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames
using Statistics
using MySQL

Invester.CheckLoadHistory()

# Update long running portfolio
pf = Invester.LoadPortfolio("testdaily")
Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today())
Invester.SavePortfolio(pf, "testdaily")
