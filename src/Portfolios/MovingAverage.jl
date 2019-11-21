@with_kw struct MovingAveragePortfolio <: AbstractPortfolio
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

    # Note: doesn't taking the last element of MAT simply correspond to instantaneous MA?!
    push!(trends, MovingAverage(assetHistory[!,:avg], 7)[end])
    push!(trends, MovingAverage(assetHistory[!,:avg], 14)[end])
    push!(trends, MovingAverage(assetHistory[!,:avg], 30)[end])
    push!(trends, MovingAverage(assetHistory[!,:avg], 90)[end])
    push!(trends, MovingAverage(assetHistory[!,:avg], 365)[end])

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
