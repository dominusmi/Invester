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
    history::IndexedTables.AbstractIndexedTable
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

struct InvestmentReturn
    value::Number
    percentage::Number
end

struct Investment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    value::Number
    invested::Number
    dateOpen::DateTime
    uuid::UUID
end
Investment{T}(asset::Asset, v::Number, invested::Number,dateOpen::GenericDate) where T <: InvestmentType =
    Investment{T}(asset,v,invested,DateTime(dateOpen),uuid1())

struct ClosedInvestment{T} <: AbstractInvestment where T <: InvestmentType
    asset::Asset
    valueOpen::Number
    valueClose::Number
    invested::Number
    dateOpen::DateTime
    dateClose::DateTime
    uuid::UUID
end
function ClosedInvestment(inv::Investment{T}, closeValue::Number, dateClose::DateTime = Date.now()) where T <: InvestmentType
    ClosedInvestment{T}(
        inv.asset, inv.value, closeValue, inv.invested, inv.dateOpen,
        dateClose, uuid1()
    )
end

InvestmentReturn(inv::Investment, closeValue::Number) = Return(inv, closeValue)
InvestmentReturn(inv::ClosedInvestment) = Return(inv)

#endregion
#region Portfolio

abstract type AbstractPortfolio end
abstract type AbstractEquityPortfolio <: AbstractPortfolio end
abstract type AbstractNonEquityPortfolio <: AbstractPortfolio end

struct Portfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment}
end
Portfolio() = Portfolio(Array{AbstractInvestment,1}())

abstract type DataAccessor end
struct LoadedDataAccessor <: DataAccessor
    history::Dict
end
Base.get(d::LoadedDataAccessor, s::Symbol, a::Any) = get(d.history, symbol, a)


#endregion

#region Utilities
abstract type AbstractDayIterator end
mutable struct WallStreetDayIterator <: AbstractDayIterator
    startDate::Date
    endDate::Date
    intervalLength::Integer
    currIteration::Integer
    """ Using end date as finish condition """
    function WallStreetDayIterator(s::Date, e::Date)
        if IsWallStreetHoliday(s)
            s = NextWallStreetDay(s)
        end
        new(s, e, 1e5, 0)
    end
    """ Using interval length as finish condition """
    function WallStreetDayIterator(s::Date, e::Integer)
        if IsWallStreetHoliday(s)
            s = NextWallStreetDay(s)
        end
        new(s, Date(3000,1,1), e, 0)
    end
end

struct DayIterator <:AbstractDayIterator
    startDate::Date
    length::Integer
end
DayIterator(s::Date, e::Date) = DayIterator(s, (e-s).value)

mutable struct DayOfWeekIterator <:AbstractDayIterator
    startDate::Date
    length::Integer
end
DayOfWeekIterator(s::Date, e::Date) = DayOfWeekIterator(s, (e-s).value)
#endregion
