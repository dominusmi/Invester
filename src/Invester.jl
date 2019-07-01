module Invester

using HTTP
using JSON
using Dates
using CSV

using Parameters
using Glob
using JuliaDB
using Query
using DataFrames: DataFrame

export Asset, AssetHistory, AssetHistoryBuffer, Investment, InvestmentType, InvestmentReturn,
	LongInvestment, ShortInvestment, AbstractInvestment, AbstractPortfolio, Portfolio, API,
	IEXTradingAPI, AlphadvantageAPI, ClosedInvestment

export LoadTop100History, PotentialProfit, Close, Close!, ClosedProfit

include("Types.jl")
include("API.jl")
include("Asset.jl")
include("Investement.jl")
include("Utilities.jl")

end # module
