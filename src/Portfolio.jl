struct MovingAveragePortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment}
end
MovingAveragePortfolio() = MovingAveragePortfolio(Array{AbstractInvestment,1}())

""" Get all open investments """
function OpenInvestments(pf::AbstractPortfolio)
    idxs = findall(x-> isopen(x), pf.investments)
    pf.investments[idxs]
end

""" Get all open investments of a given asset """
function OpenInvestments(pf::AbstractPortfolio, a::Asset)
    idxs = findall(x-> isopen(x) && x.asset == a, pf.investments)
    pf.investments[idxs]
end

#region Moving Average Portfolio

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

function CloseConfidence(investment::Investment, pf::MovingAveragePortfolio, date::Date = Dates.today())
    history = CheckLoadHistory()

    currentValue = FetchCloseAssetValue(investment.asset, date)
    pot = PotentialProfitPercentage(investment, currentValue)

    if pot > 0.05 || pot < 0.05
        return 1
    end
    return 0
end

#endregion
