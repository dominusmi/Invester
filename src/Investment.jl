isOpenInvestment(i::AbstractInvestment)::Bool = typeof(i) <: Investment
isClosedInvestment(i::AbstractInvestment)::Bool = typeof(i) <: ClosedInvestment

isOpen(i::Investment, d::GenericDate) = Date(i.dateOpen) < Date(d)
isOpen(i::ClosedInvestment, d::GenericDate) = Date(i.dateOpen) < Date(d) && Date(i.dateClose) > Date(d)


Add!(portfolio::AbstractPortfolio, inv::AbstractInvestment) = push!(portfolio.investments, inv)

function Long!(portfolio::AbstractPortfolio, asset::Asset, value::Number, investedAmount::Number;
        dateOpen::GenericDate = Dates.now())

    inv = Investment{LongInvestment}(asset, value, investedAmount, dateOpen)
    Add!(portfolio, inv)
end

function Long!(portfolio::AbstractPortfolio, asset::Asset, investedAmount::Number, dateOpen::GenericDate)
    value = FetchAverageAssetValue(asset, dateOpen)
    Long!(portfolio, asset, value, investedAmount, dateOpen = dateOpen)
end

function Short!(portfolio::AbstractPortfolio, asset::Asset, value::Number;
        dateOpen::DateTime = Dates.now())

    inv = Investment{ShortInvestment}(asset, value, dateOpen)
    add!(portfolio, inv)
end
function Short!(portfolio::AbstractPortfolio, asset::Asset, dateOpen::DateTime)
    value = FetchAverageAssetValue(asset, dateOpen)
    Short!(portfolio, asset, value, dateOpen = dateOpen)
end

Close(inv::Investment, value::Number, dateClose::DateTime = Dates.now()) = ClosedInvestment(inv, value, dateClose)


function Close!(pf::AbstractPortfolio, uuid::UUID, value::Number, dateClose::DateTime = Date.Today())
    idx = findfirst(x -> x.uuid == uuid, pf.investments)
    pf.investments[idx] = Close(pf.investments[idx], value, dateClose)
end
function Close!(pf::AbstractPortfolio, inv::Investment, value::Number, dateClose::DateTime = Date.Today())
    Close!(pf, inv.uuid, value, dateClose)
end

"""
    Returns the real amount (e.g. euro difference) for investment, and the percentage
    profit in float format (i.e. 1.8% => 0.018, and not 1.8)
"""
function Return(inv::Investment{LongInvestment}, value::Number)::InvestmentReturn
    _valueDiff = Float64(value) - inv.value
    perc = (_valueDiff) / inv.value
    InvestmentReturn(perc * inv.invested, perc)
end
function Return(inv::Investment{ShortInvestment}, value::Number)::InvestmentReturn
    _return = Float64(inv.value) - value
    perc = (_return) / inv.value
    InvestmentReturn(perc * inv.invested, perc)
end
function Return(inv::ClosedInvestment, value::Number)::InvestmentReturn
    _return = value - Float64(inv.valueOpen)
    perc = (_return) / inv.valueOpen
    InvestmentReturn(perc * inv.invested, perc)
end
function Return(inv::ClosedInvestment)::InvestmentReturn
    _return = inv.valueClose - Float64(inv.valueOpen)
    perc = (_return) / inv.valueOpen
    InvestmentReturn(perc * inv.invested, perc)
end

PotentialProfit(inv::AbstractInvestment) = 0.
PotentialProfit(inv::AbstractInvestment, args...) = 0.
ClosedProfit(inv::AbstractInvestment) = 0.
ClosedProfitPercentage(inv::AbstractInvestment) = 0.

ClosedProfit(inv::ClosedInvestment) = Return(inv).value
ClosedProfitPercentage(inv::ClosedInvestment) = Return(inv).percentage

PotentialProfit(inv::AbstractInvestment, currentValue::Number)::Number =
    Return(inv, currentValue).value
PotentialProfitPercentage(inv::AbstractInvestment, currentValue::Number)::Number =
    Return(inv, currentValue).percentage

function PotentialProfit(inv::Investment, date::GenericDate)::Number
    date = Date(date)
    currentValue = FetchCloseAssetValue(inv.asset, date)
    return Return(inv, currentValue).value
end

function PotentialProfitPercentage(inv::Investment, date::GenericDate)::Number
    date = Date(date)
    currentValue = FetchCloseAssetValue(inv.asset, date)
    return Return(inv, currentValue).percentage
end

ValueOpen(i::Investment) = i.value
ValueOpen(i::ClosedInvestment) = i.valueOpen

DateOpen(i::AbstractInvestment) = i.dateOpen

Asset(i::AbstractInvestment) = i.asset

# Convert milliseconds to days
""" Duration in days (possibly partial) of a closed investment """
Duration(inv::ClosedInvestment)::Number = (inv.dateClose - inv.dateOpen).value / 86400000
