#region API

abstract type API end
struct IEXTradingAPI <: API
    base::String
end
IEXTradingAPI() = IEXTradingAPI("https://ws-api.iextrading.com/1.0")

struct AlphadvantageAPI <: API
    key::String
    base::String
end
AlphadvantageAPI() = AlphadvantageAPI("3J1NP4X808DF2YY8", "https://www.alphavantage.co/query?")
#endregion

#region Asset
struct Asset
    symbol::Symbol
    Asset(s::String) = new(Symbol(s))
end


@with_kw mutable struct AssetHistoryBuffer
    asset::Asset
    dates::Array{Date}                   = Array{Date,1}()
    open::Array{<:AbstractFloat}         = zeros()
    high::Array{<:AbstractFloat}         = zeros()
    close::Array{<:AbstractFloat}        = zeros()
    close_adjusted::Array{<:AbstractFloat} = zeros()
    low::Array{<:AbstractFloat}          = zeros()
    volume::Array{<:AbstractFloat}       = zeros()
    dividend::Array{<:AbstractFloat}     = zeros()
    split_coef::Array{<:AbstractFloat}   = zeros()
end

struct AssetHistory
    asset::Asset
    history::IndexedTable
end
AssetHistory(symbol::String) = AssetHistory(Symbol(symbol))
AssetHistory(asset::Asset) = AssetHistory(asset.symbol)

function AssetHistory(asset::Asset, df::DataFrame)
    AssetHistory(
        asset, loadtable(df, pkey = [:timestamp]))
end

function AssetHistory(buffer::AssetHistoryBuffer)
   history = table((timestamp=buffer.dates, open=buffer.open, high=buffer.high, close=buffer.close,
            adjusted_close=buffer.close_adjusted, low=buffer.low, volume=buffer.volume,
            dividend_amount=buffer.dividend,split_coefficient=buffer.split_coef),
            pkey=[:timestamp])

    AssetHistory(buffer.asset.symbol, history)
end
#endregion

#region Investement
abstract type InvestmentType end
abstract type LongInvestment <: InvestmentType end
abstract type ShortInvestment <: InvestmentType end

struct InvestmentReturn
    value::AbstractFloat
    percentage::AbstractFloat
end

abstract type AbstractInvestment end

struct Investment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    value::AbstractFloat
    dateOpen::Date
end

struct ClosedInvestment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    valueOpen::AbstractFloat
    valueClose::AbstractFloat
    dateOpen::DateTime
    dateClosed::DateTime
    closed::InvestmentReturn
end


abstract type AbstractPortfolio end

struct Portfolio <: AbstractPortfolio
    Investments::Array{<:AbstractInvestment}
end

#endregion
