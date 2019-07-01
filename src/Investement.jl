function InvestementReturn(inv::Investment{T}, closeValue::AbstractFloat) where T <: InvestmentType
    _return = Return(inv, closeValue)
    percentage = (inv.value + _return) / inv.value
    InvestementReturn(_return, percentage)
end

function ClosedInvestment(inv::Investment{T}, closeValue::AbstractFloat, dateClosed::Date = Date.now()) where T <: InvestmentType
    ClosedInvestment{T}(
        inv.asset, inv.value, closeValue, inv.dateOpen,
        datedClosed, InvestmentReturn(inv, closeValue)
    )
end

Add!(portfolio::AbstractPortfolio, inv::AbstractInvestment) = push!(portfolio.Investments, inv)

function Long!(portfolio::AbstractPortfolio, asset::Asset, value::AbstractFloat;
        dateOpen::Date = Dates.today())

    inv = Investment{LongInvestment}(asset, value, dateOpen)
    add!(portfolio, inv)
end

function Short!(portfolio::AbstractPortfolio, asset::Asset, value::AbstractFloat;
        dateOpen::Date = Dates.today())

    inv = Investment{ShortInvestment}(asset, value, dateOpen)
    add!(portfolio, inv)
end

Close(inv::Investment, value::AbstractFloat, dateClosed::DateTime) = ClosedInvestment(inv, value, dateClosed)

function Close!(pf::AbstractPortfolio, inv::Investment, value::AbstractFloat, dateClosed::DateTime = Date.Today())
    idx = findfirst(pf.Investments, x => x == inv)
    pf.Investments[idx] = Close(inv, value, dateClosed)
end

Return(inv::Investment{LongInvestment}, value::AbstractFloat) = value - inv.value
Return(inv::Investment{ShortInvestment}, value::AbstractFloat) = inv.value - value

PotentialProfit(inv::AbstractInvestment) = 0.
ClosedProfit(inv::AbstractInvestment) = 0.
ClosedPercentage(inv::AbstractInvestment) = 0.

ClosedProfit(inv::ClosedInvestment) = inv.close.value
ClosedPercentage(inv::ClosedInvestment) = inv.close.percentage

function PotentialProfit(inv::Investment; currentValue::Union{AbstractFloat,Nothing} = nothing,
    dateTime::DateTime = Dates.now())

    if isnothing(currentValue)
        currentValue = FetchAssetValue(inv.asset, dateTime)
    end

    return Return(inv, currentValue)
end

function PotentialProfit(pf::AbstractPortfolio)
    total = 0.
    for inv in pf.investestements
        total += PotentialProfit(inv)
    end
end

function ClosedProfit(pf::AbstractPortfolio)
    total = 0.
    for inv in pf.investestements
        total += ClosedProfit(inv)
    end
end
