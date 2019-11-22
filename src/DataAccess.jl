function CheckLoadHistory()
    global history
    if isempty(history)
        history = LoadTop100History()
    end
    history
end

function ReloadHistory()
    global history
    history = LoadTop100History()
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

    df = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select (open=h[:open],timestamp=h[:timestamp])
            @collect DataFrame
    end
    if df[end,:timestamp] != date
        LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(df[end,:timestamp])")
    end
    df[end, :open]
end

function FetchCloseAssetValue(asset::Asset, date::GenericDate)::Number
    history = CheckLoadHistory()

    df = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select (adjusted_close=h[:adjusted_close],timestamp=h[:timestamp])
            @collect DataFrame
    end
    if df[end,:timestamp] != date
        LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(df[end,:timestamp])")
    end
    df[end, :adjusted_close]
end
