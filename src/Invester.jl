module Invester

using JSON
using Dates
using CSV

using Parameters
using Glob
using JuliaDB
using Query
using DataFrames: DataFrame, DataFrameRow
using Statistics
using UUIDs
using HTTP
using MySQL
using OnlineStats
using IndexedTables

import Base.==, Base.~

export Asset, AssetHistory, AssetHistoryBuffer, Investment, InvestmentType, InvestmentReturn,
	LongInvestment, ShortInvestment, AbstractInvestment, AbstractPortfolio, Portfolio, API,
	IEXTradingAPI, AlphadvantageAPI, ClosedInvestment, isOpen, ValueOpen,

	LoadTop100History, PotentialProfit, ClosedPercentage, ClosedProfit, Close,
	Close!, ClosedProfit, Return, Add!, Long!, Short!, FetchAverageAssetValue,
	MovingAverage, OneWeekMA, OneMonthMA, ThreeMonthsMA, SixMonthsMA,
	CheckLoadHistory, PotentialProfitPercentage, ReloadHistory,

	ClosedProfitPercentage, ClosedInvestments, OpenInvestments, isOpenInvestment, isClosedInvestment,
	InvestmentsClosedOn, InvestmentsOpenedOn, InvestmentsOpenOn, ValueOpen, DateOpen,

	Select,
	# Date - DateTime comparison function
	~

const global BASE_PATH = dirname(pathof(Invester))
const global ROOT_PATH = realpath(dirname(pathof(Invester))*"/..")
const global CONFIG_PATH = ROOT_PATH * "/Config"

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
include("Portfolios/MovingAverageWithTrend.jl")
include("Brain.jl")
include("Utilities/DateUtilities.jl")
include("Utilities/Logging.jl")
include("DatabaseHandle.jl")


history = Dict{Symbol, AssetHistory}()
DbConnection = nothing
end # module
