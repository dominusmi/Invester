@with_kw struct MovingAveragePortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}()
    lowerClosePercentageThreshold::Number = -5
    upperClosePercentageThreshold::Number = 5
    maxInvestments = 1e4
    longThreshold = 0.5
    closeThreshold = 0.5
end

function LongConfidence(asset::Asset, pf::MovingAveragePortfolio, date::Date = Dates.today())
    history = CheckLoadHistory()

    assetHistory = @from h in history[asset.symbol].history begin
    	@where  h[:timestamp] >= date - Day(720) &&
    			h[:timestamp] <= date
    	@select (open = h[:open], adjusted_close = h[:adjusted_close],
    		avg = mean([h[:open],h[:adjusted_close]]))
    	@collect DataFrame
    end

    trends = zeros(0)

    if size(assetHistory[:avg],1) < 365
        return 0
    end

    push!(trends, MovingAverageTrend(assetHistory[:avg], 7)[end])
    push!(trends, MovingAverageTrend(assetHistory[:avg], 14)[end])
    push!(trends, MovingAverageTrend(assetHistory[:avg], 30)[end])
    push!(trends, MovingAverageTrend(assetHistory[:avg], 90)[end])
    push!(trends, MovingAverageTrend(assetHistory[:avg], 365)[end])

    # Check how many of the trends indicate future improvement
    _sum = trends |>
        t -> (t .> assetHistory[:avg][end]) |>
        sum

    return _sum / 5.
end

function CloseConfidence(investment::Investment, pf::MovingAveragePortfolio,
                         date::Date = Dates.today())

    history = CheckLoadHistory()

    currentValue = FetchCloseAssetValue(investment.asset, date)
    pot = PotentialProfitPercentage(investment, currentValue)

    if pot > UpperClosePercentageThreshold(pf) || pot < LowerClosePercentageThreshold(pf)
        return 1
    end
    return 0
end

function Hook(pf::MovingAveragePortfolio, day::Date, logger)
    nothing
end
