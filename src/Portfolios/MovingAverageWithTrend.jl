@with_kw struct MovingAverageWithTrendPortfolio <: AbstractNonEquityPortfolio
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}()
    lowerClosePercentageThreshold::Number = -0.06
    upperClosePercentageThreshold::Number = 0.02
    maxInvestments::Integer = 1e4
    longThreshold::Number = 0.5
    closeThreshold::Number = 0.5
    trendWindow::Integer = 3
    movingAverageWindow::Integer = 4
end


function LongConfidence(asset::Asset, pf::MovingAverageWithTrendPortfolio, date::Date = Dates.today())
    history = CheckLoadHistory()

    assetHistory = FetchOpenCloseAssetHistory(asset, date; daysInHistory=365)

    minimumSequenceLength = pf.trendWindow * pf.movingAverageWindow
    if size(assetHistory,1) < minimumSequenceLength+2
        return 0
    end

    # Calculate moving averages over last days (to calculate the linear trend)
    MAs = MovingAverage(assetHistory[(end-minimumSequenceLength-1):end,:adjusted_close], pf.movingAverageWindow)

    # Calculate trend of moving average
    subArrayMAs = MAs[(end-pf.trendWindow): end]
    trend = LinearTrend(subArrayMAs)
    currMA = MAs[end]

    # If current moving average is higher than price (asset undervalued) and trend is upward
    if currMA > assetHistory[!,:adjusted_close][end] && trend > 0
        # Any excess is used for extra confidence
        return trend + .5
    end
    return 0
end

function CloseConfidence(investment::Investment, pf::MovingAverageWithTrendPortfolio,
                         date::Date = Dates.today())

    history = CheckLoadHistory()
    asset = investment.asset

    currentValue = FetchCloseAssetValue(asset, date)
    if currentValue == nothing
        return 0
    end

    pot = PotentialProfitPercentage(investment, currentValue)

    assetHistory = FetchOpenCloseAssetHistory(asset, date; daysInHistory=365)

    minimumSequenceLength = pf.trendWindow * pf.movingAverageWindow
    if size(assetHistory,1) < minimumSequenceLength+1
        return 0
    end

    # Calculate moving averages over last days (to calculate the linear trend)
    MAs = MovingAverage(assetHistory[(end-minimumSequenceLength-1):end,:adjusted_close], pf.movingAverageWindow)

    # Calculate trend of moving average
    subArrayMAs = MAs[(end-pf.trendWindow): end]
    trend = LinearTrend(subArrayMAs)


    if pot > UpperClosePercentageThreshold(pf) || pot < LowerClosePercentageThreshold(pf) || (pot > 0 && trend < 0)
        return 1
    end
    return 0
end
