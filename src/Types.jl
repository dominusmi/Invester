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
    dates::Array{Date}            = Array{Date,1}()
    open::Array{<:Number}         = zeros()
    high::Array{<:Number}         = zeros()
    close::Array{<:Number}        = zeros()
    close_adjusted::Array{<:Number} = zeros()
    low::Array{<:Number}          = zeros()
    volume::Array{<:Number}       = zeros()
    dividend::Array{<:Number}     = zeros()
    split_coef::Array{<:Number}   = zeros()
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

abstract type AbstractInvestment end

==(inv1::AbstractInvestment, inv2::AbstractInvestment) = (inv1.uuid == inv2.uuid)

struct Investment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    value::Number
    dateOpen::DateTime
    uuid::UUID
end
Investment{T}(asset::Asset, v::Number, dateOpen::DateTime) where T <: InvestmentType =
    Investment{T}(asset,v,dateOpen,uuid1())


struct InvestmentReturn
    value::Number
    percentage::Number
end
InvestmentReturn(inv::Investment, closeValue::Number) = Return(inv, closeValue)


struct ClosedInvestment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    valueOpen::Number
    valueClose::Number
    dateOpen::DateTime
    dateClosed::DateTime
    closedReturn::InvestmentReturn
    uuid::UUID
end
function ClosedInvestment(inv::Investment{T}, closeValue::Number, dateClosed::DateTime = Date.now()) where T <: InvestmentType
    ClosedInvestment{T}(
        inv.asset, inv.value, closeValue, inv.dateOpen,
        dateClosed, InvestmentReturn(inv, closeValue), uuid1()
    )
end

abstract type AbstractPortfolio end

struct Portfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment}
end
Portfolio() = Portfolio(Array{AbstractInvestment,1}())

#endregion
