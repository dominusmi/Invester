@with_kw struct MovingAverageWithTrendPortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}()
    lowerClosePercentageThreshold::Number = -5
    upperClosePercentageThreshold::Number = 5
    maxInvestments::Integer = 1e4
    longThreshold::Number = 0.5
    closeThreshold::Number = 0.5
end


function LongConfidence(asset::Asset, pf::MovingAveragePortfolio, date::Date = Dates.today())
    history = CheckLoadHistory()

    assetHistory = @from h in history[asset.symbol].history begin
    	@where  h[:timestamp] >= date - Day(365) &&
    			h[:timestamp] <= date
    	@select (open = h[:open], adjusted_close = h[:adjusted_close],
    		avg = mean([h[:open],h[:adjusted_close]]))
    	@collect DataFrame
    end

    MAs = MovingAverage(assetHistory[(end-10):end,:adjusted_close], 3)
    trend = LinearTrend(MAs, 3)
    currMA = InstantaneousMovingAverage(assetHistory[!,:adjusted_close], 10))

    if currMA < assetHistory[!,:adjusted_close][end] && trend > 0
        # Any excess is used for extra confidence
        return trend + .5
    end
    return 0
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
