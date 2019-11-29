module Invester

using JSON
using Parameters, UUIDs, Glob, CSV, Dates
using JuliaDB
using Query
using IndexedTables
using DataFrames: DataFrame, DataFrameRow
using Statistics
using OnlineStats
using HTTP
using MySQL
using Flux
using BSON
using CuArrays
using Base: eachrow, eachcol

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
	# Operator for Date - DateTime comparison function
	~

const global BASE_PATH = dirname(pathof(Invester))
const global ROOT_PATH = realpath(dirname(pathof(Invester))*"/..")
const global CONFIG_PATH = ROOT_PATH * "/Config"

const global ENVIRONMENT = JSON.parsefile(Invester.CONFIG_PATH * "/appconfig.json")["Environment"]

const global USING_GPU = parse(Bool, JSON.parsefile(Invester.CONFIG_PATH * "/appconfig.$ENVIRONMENT.json")["Using_GPU"])

GenericDate = Union{Date,DateTime}

CuArrays.allowscalar(false)

include("Types.jl")
include("API.jl")
include("Asset.jl")
include("Investment.jl")
include("Utilities.jl")
include("DataAccess.jl")
include("Analysis.jl")
include("Portfolio.jl")
include("Brain.jl")
include("Utilities/DateUtilities.jl")
include("Utilities/Logging.jl")
include("DatabaseHandle.jl")
include("Utilities/TimeSeriesUtilities.jl")
include("Utilities/FinancialMetrics.jl")
include("Portfolios/MovingAverage.jl")
include("Portfolios/MovingAverageWithTrend.jl")
include("Portfolios/FinancialMetricsCNN.jl")



history = Dict{Symbol, AssetHistory}()
DbConnection = nothing
end # module
