@with_kw struct MovingAveragePortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}()
    lowerClosePercentageThreshold::Number = -6
    upperClosePercentageThreshold::Number = 2
    maxInvestments::Integer = 1e4
    longThreshold::Number = 0.5
    closeThreshold::Number = 0.5
end


function LongConfidence(asset::Asset, pf::MovingAveragePortfolio, date::Date = Dates.today())
    assetHistory = FetchOpenCloseAssetHistory(asset, date)
    trends = zeros(0)

    if size(assetHistory[!,:avg],1) < 365
        return 0
    end

    # Note: doesn't taking the last element of MAT simply correspond to instantaneous MA?!
    push!(trends, InstantaneousMovingAverage(assetHistory[!,:avg], 7))
    push!(trends, InstantaneousMovingAverage(assetHistory[!,:avg], 14))
    push!(trends, InstantaneousMovingAverage(assetHistory[!,:avg], 30))
    push!(trends, InstantaneousMovingAverage(assetHistory[!,:avg], 90))
    push!(trends, InstantaneousMovingAverage(assetHistory[!,:avg], 365))

    # Check how many of the trends indicate future improvement
    _sum = trends |>
        t -> (t .> assetHistory[end, :avg]) |>
        sum

    return _sum / 5.
end

function CloseConfidence(investment::Investment, pf::MovingAveragePortfolio,
                         date::Date = Dates.today())

    history = CheckLoadHistory()

    currentValue = FetchCloseAssetValue(investment.asset, date)
    if currentValue == nothing
        return 0
    end

    pot = PotentialProfitPercentage(investment, currentValue)

    if pot > UpperClosePercentageThreshold(pf) || pot < LowerClosePercentageThreshold(pf)
        return 1
    end
    return 0
end

function Hook(pf::MovingAveragePortfolio, day::Date, logger)
    nothing
end


#region Profit calculation functions

function PotentialProfitPercentage(pf::MovingAveragePortfolio, date::GenericDate = Dates.today()-Dates.Day(1))
    date = Date(date)
    total = 0.
    for inv in OpenInvestments(pf)
        total += PotentialProfitPercentage(inv, date) / inv.invested
    end
    total / pf.maxInvestments
end

function ClosedProfitPercentage(pf::MovingAveragePortfolio)
    total = 0.
    for inv in ClosedInvestments(pf)
        total += ClosedProfitPercentage(inv)
    end
    total / pf.maxInvestments
end

#endregion
