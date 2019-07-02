Add!(portfolio::AbstractPortfolio, inv::AbstractInvestment) = push!(portfolio.Investments, inv)

function Long!(portfolio::AbstractPortfolio, asset::Asset, value::Number;
        dateOpen::DateTime = Dates.now())

    inv = Investment{LongInvestment}(asset, value, dateOpen)
    add!(portfolio, inv)
end

function Long!(portfolio::AbstractPortfolio, asset::Asset, dateOpen::Union{DateTime,Date})
    value = FetchAverageAssetValue(asset, dateOpen)
    Long!(portfolio, asset, value, dateOpen = dateOpen)
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

Close(inv::Investment, value::Number; dateClosed::DateTime = Dates.now()) = ClosedInvestment(inv, value, dateClosed)

function Close!(pf::AbstractPortfolio, inv::Investment, value::Number, dateClosed::DateTime = Date.Today())
    idx = findfirst(pf.Investments, x => x == inv)
    pf.Investments[idx] = Close(inv, value, dateClosed)
end

function Return(inv::Investment{LongInvestment}, value::Number)
    _return = Float64(value) - inv.value
    perc = (_return) / inv.value * 100
    InvestmentReturn(_return, perc)
end
function Return(inv::Investment{ShortInvestment}, value::Number)
    _return = Float64(inv.value) - value
    perc = (_return) / inv.value * 100
    InvestmentReturn(_return, perc)
end

PotentialProfit(inv::AbstractInvestment) = 0.
ClosedProfit(inv::AbstractInvestment) = 0.
ClosedPercentage(inv::AbstractInvestment) = 0.

ClosedProfit(inv::ClosedInvestment) = inv.closedReturn.value
ClosedPercentage(inv::ClosedInvestment) = inv.closedReturn.percentage

PotentialProfit(inv::Investment, currentValue::Number) = Return(inv, currentValue).value

function PotentialProfit(inv::Investment, dateTime::DateTime)
    currentValue = FetchAverageAssetValue(inv.asset, dateTime)
    return Return(inv, currentValue).value
end

function PotentialProfit(pf::AbstractPortfolio, dateTime::DateTime = DateTime.now())
    total = 0.
    for inv in pf.investestements
        total += PotentialProfit(inv, dateTime)
    end
end

function ClosedProfit(pf::AbstractPortfolio)
    total = 0.
    for inv in pf.investestements
        total += ClosedProfit(inv)
    end
end
