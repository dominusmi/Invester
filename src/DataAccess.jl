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
            @where h[:timestamp] <= Date(date)
            @select (open=h[:open],timestamp=h[:timestamp])
            @collect DataFrame
    end
    # if df[end,:timestamp] != date
        # LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(df[end,:timestamp])")
    # end
    df[end, :open]
end

function FetchCloseAssetValue(asset::Asset, date::GenericDate)::Number
    history = CheckLoadHistory()

    df = @from h in history[asset.symbol].history begin
            @where h[:timestamp] <= Date(date) && h[:timestamp] > Date(date)-Dates.Day(10)
            @select (adjusted_close=h[:adjusted_close],timestamp=h[:timestamp])
            @collect DataFrame
    end
    # if df[end,:timestamp] != date
        # LogWarn("Couldn't fetch asset value for $(asset.symbol) on $date, instead fetched $(df[end,:timestamp])")
    # end
    df[end, :adjusted_close]
end

function FetchOpenCloseAssetHistory(asset::Asset, date::GenericDate; daysInHistory::Integer=720)
    history = CheckLoadHistory()

    return @from h in history[asset.symbol].history begin
    	@where  h[:timestamp] >= Date(date) - Day(daysInHistory) &&
    			h[:timestamp] <= Date(date)
    	@select (open = h[:open], adjusted_close = h[:adjusted_close],
    		avg = mean([h[:open],h[:adjusted_close]]), timestamp=h[:timestamp])
    	@collect DataFrame
    end
end


function FetchAssetVolume(asset::Asset, date::GenericDate)::Number
    history = CheckLoadHistory()

    arr = @from h in history[asset.symbol].history begin
            @where h[:timestamp] <= Date(date) && h[:timestamp] > Date(date)-Dates.Day(10)
            @select volume=h[:volume]
            @collect
    end
    arr[end]
end


function FetchAssetHistory(asset::Asset, date::GenericDate; daysInHistory::Integer=720)
    history = CheckLoadHistory()

    return @from h in history[asset.symbol].history begin
    	@where  h[:timestamp] >= Date(date) - Day(daysInHistory) &&
    			h[:timestamp] <= Date(date)
    	@select (open = h[:open], adjusted_close = h[:adjusted_close],
    		avg = mean([h[:open], h[:adjusted_close]]), timestamp=h[:timestamp],
            volume=h[:volume], high=h[:high], low=h[:low])
    	@collect DataFrame
    end
end
