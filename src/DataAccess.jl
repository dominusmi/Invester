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

    value[1]
end


function FetchAverageAssetValue(asset::Asset, startDate::GenericDate, endDate::GenericDate)
    history = CheckLoadHistory()

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] >= startDate && h[:timestamp] <= endDate
            @select mean([h[:open], h[:adjusted_close]])
            @collect
    end

    value
end
