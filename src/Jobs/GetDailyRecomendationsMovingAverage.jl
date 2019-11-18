using Invester
using Plots
using Dates, Query, JuliaDB, DataFrames
using Statistics
using MySQL

Invester.CheckLoadHistory()

pf = Invester.LoadPortfolio("testdaily")

pf
Invester.SimulatePortfolioDecisionMaker(pf, Dates.today() - Dates.Day(1), Dates.today())
pf.investments

Invester.SavePortfolio(pf, "testdaily")
