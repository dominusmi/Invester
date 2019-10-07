module Invester

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

import Base.==, Base.~

export Asset, AssetHistory, AssetHistoryBuffer, Investment, InvestmentType, InvestmentReturn,
	LongInvestment, ShortInvestment, AbstractInvestment, AbstractPortfolio, Portfolio, API,
	IEXTradingAPI, AlphadvantageAPI, ClosedInvestment, isOpen, ValueOpen,

	LoadTop100History, PotentialProfit, ClosedPercentage, ClosedProfit, Close,
	Close!, ClosedProfit, Return, Add!, Long!, Short!, FetchAverageAssetValue,
	MovingAverage, OneWeekMA, OneMonthMA, ThreeMonthsMA, SixMonthsMA,
	CheckLoadHistory, PotentialProfitPercentage,

	ClosedProfitPercentage, ClosedInvestments, OpenInvestments, isOpenInvestment, isClosedInvestment,
	InvestmentsClosedOn, InvestmentsOpenedOn, InvestmentsOpenOn,

	Select,
	# Date - DateTime comparison function
	~


GenericDate = Union{Date,DateTime}

include("Types.jl")
include("API.jl")
include("Asset.jl")
include("Investment.jl")
include("Utilities.jl")
include("DataAccess.jl")
include("Analysis.jl")
include("Portfolio.jl")
include("Portfolios/MovingAverage.jl")
include("Brain.jl")


history = Dict{Symbol, AssetHistory}()

end # module
