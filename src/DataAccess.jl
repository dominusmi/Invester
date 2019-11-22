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

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select h[:open]
            @collect
    end
    if isempty(value)
        # If date not defined, get latest
        value = @from h in history[asset.symbol].history begin
                @where h[:timestamp] < Date(date)
                @select h[:open]
                @collect
        end
        LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(value[end])")
    end
    value[1]
end

function FetchCloseAssetValue(asset::Asset, date::GenericDate)::Number
    history = CheckLoadHistory()

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == Date(date)
            @select h[:adjusted_close]
            @collect
    end
    if isempty(value)
        # If date not defined, get last before
        value = @from h in history[asset.symbol].history begin
                @where h[:timestamp] < Date(date)
                @select h[:adjusted_close]
                @collect
        end
        LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(value[end])")
    end
    value[end]
end
