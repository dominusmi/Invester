function CheckLoadHistory()
    global history
    if isempty(history)
        history = LoadTop100History()
    end
    history
end

""" Fetches the average between open and close for a given date """
function FetchAverageAssetValue(asset::Asset, date::GenericDate)
    history = CheckLoadHistory()
    date = Date(date)
    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == date
            @select mean([h[:open], h[:adjusted_close]])
            @collect
    end
    try
        return value[1]
    catch e
        @show asset.symbol, date
        throw(e)
    end
end


function FetchAverageAssetValue(asset::Asset, startDate::GenericDate, endDate::GenericDate)
    history = CheckLoadHistory()

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] >= Date(startDate) && h[:timestamp] <= Date(endDate)
            @select mean([h[:open], h[:adjusted_close]])
            @collect
    end

    value
end

function FetchOpenAssetValue(asset::Asset, date::GenericDate)
    history = CheckLoadHistory()

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select h[:open]
            @collect
    end

    value[1]
end

function FetchCloseAssetValue(asset::Asset, date::GenericDate)
    history = CheckLoadHistory()

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select h[:adjusted_close]
            @collect
    end

    value[1]
end
