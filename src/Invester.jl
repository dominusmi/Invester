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
using Statistics
using UUIDs

import Base.==

export Asset, AssetHistory, AssetHistoryBuffer, Investment, InvestmentType, InvestmentReturn,
	LongInvestment, ShortInvestment, AbstractInvestment, AbstractPortfolio, Portfolio, API,
	IEXTradingAPI, AlphadvantageAPI, ClosedInvestment

export LoadTop100History, PotentialProfit, ClosedPercentage, ClosedProfit, Close,
	Close!, ClosedProfit, Return, Add!, Long!, Short!

include("Types.jl")
include("API.jl")
include("Asset.jl")
include("Investment.jl")
include("Utilities.jl")

history = Dict{Symbol, AssetHistory}()

end # module
