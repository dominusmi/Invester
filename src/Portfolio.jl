struct MovingAveragePortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment}
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

    trends = zeros(0,0)

    push!(trends, MovingAverageTrend(assetHistory[:avg], 7))
    push!(trends, MovingAverageTrend(assetHistory[:avg], 14))
    push!(trends, MovingAverageTrend(assetHistory[:avg], 30))
    push!(trends, MovingAverageTrend(assetHistory[:avg], 90))
    push!(trends, MovingAverageTrend(assetHistory[:avg], 365))

    # Check how many of the trends indicate future improvement
    trends |>
    t -> (t .> assetHistory[:avg]) |>
    sum

    return sum / 5.
end
