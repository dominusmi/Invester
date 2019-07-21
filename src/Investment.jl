isopen(i::AbstractInvestment)::Bool = typeof(i) <: Investment
isclosed(i::AbstractInvestment)::Bool = typeof(i) <: ClosedInvestment

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

Close(inv::Investment, value::Number, dateClosed::DateTime = Dates.now()) = ClosedInvestment(inv, value, dateClosed)


function Close!(pf::AbstractPortfolio, uuid::UUID, value::Number, dateClosed::DateTime = Date.Today())
    idx = findfirst(x -> x.uuid == uuid, pf.investments)
    pf.investments[idx] = Close(pf.investments[idx], value, dateClosed)
end
function Close!(pf::AbstractPortfolio, inv::Investment, value::Number, dateClosed::DateTime = Date.Today())
    Close!(pf, inv.uuid, value, dateClosed)
end


function Return(inv::Investment{LongInvestment}, value::Number)::InvestmentReturn
    _valueDiff = Float64(value) - inv.value
    perc = (_valueDiff) / inv.value
    InvestmentReturn(perc * inv.invested, perc * 100)
end
function Return(inv::Investment{ShortInvestment}, value::Number)::InvestmentReturn
    _return = Float64(inv.value) - value
    perc = (_return) / inv.value
    InvestmentReturn(perc * inv.invested, perc * 100)
end
Return(inv::ClosedInvestment) = inv.closedReturn

PotentialProfit(inv::AbstractInvestment) = 0.
PotentialProfit(inv::AbstractInvestment, args...) = 0.
ClosedProfit(inv::AbstractInvestment) = 0.
ClosedProfitPercentage(inv::AbstractInvestment) = 0.

ClosedProfit(inv::ClosedInvestment) = inv.closedReturn.value
ClosedProfitPercentage(inv::ClosedInvestment) = inv.closedReturn.percentage

PotentialProfit(inv::Investment, currentValue::Number)::InvestmentReturn =
    Return(inv, currentValue).value
PotentialProfitPercentage(inv::Investment, currentValue::Number)::InvestmentReturn =
    Return(inv, currentValue).percentage

function PotentialProfit(inv::Investment, date::GenericDate)::InvestmentReturn
    date = Date(date)
    currentValue = FetchAverageAssetValue(inv.asset, date)
    return Return(inv, currentValue).value
end

function PotentialProfitPercentage(inv::Investment, date::GenericDate)::InvestmentReturn
    date = Date(date)
    currentValue = FetchAverageAssetValue(inv.asset, date)
    return Return(inv, currentValue).percentage
end


Duration(inv::ClosedInvestment)::Integer = (inv.DateClose - inv.dateOpen).value
