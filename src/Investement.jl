Add!(portfolio::AbstractPortfolio, inv::AbstractInvestment) = push!(portfolio.Investments, inv)

function Long!(portfolio::AbstractPortfolio, asset::Asset, value::AbstractFloat;
        dateOpen::Date = Dates.today(), dateClose::Union{Date,Nothing} = nothing)

    inv = Investment{LongInvestment}(asset, value, dateOpen, dateClose)
    add!(portfolio, inv)
end

function Short!(portfolio::AbstractPortfolio, asset::Asset, value::AbstractFloat;
        dateOpen::Date = Dates.today(), dateClose::Union{Date,Nothing} = nothing)

    inv = Investment{ShortInvestment}(asset, value, dateOpen, dateClose)
    add!(portfolio, inv)
end

function Close!(pf::AbstractPortfolio, inv::Investment)
    findfirst(pf.Investments, x => x == inv)
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
