@with_kw struct MovingAveragePortfolio <: AbstractNonEquityPortfolio
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}()
    lowerClosePercentageThreshold::Number = -0.06
    upperClosePercentageThreshold::Number = 0.02
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
