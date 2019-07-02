function LoadTop100History()::Dict{Symbol, AssetHistory}
   assetHistories = Dict{Symbol, AssetHistory}()
    for path in glob("*.csv", "src/resources/Top100Companies/")
        symbol = split( split(path, '/')[end], '.')[1]
        asset = Asset(String(symbol))

        @show "Loading $(symbol)"

        hist = loadtable(path, indexcols=["timestamp"])
        assetHistory = AssetHistory(asset,hist)
        assetHistories[asset.symbol] = assetHistory
    end
    return assetHistories
end

function SaveStocksHistory()
    df = CSV.File("resources/1billion_companies.tsv", delim='\t')
    aa = AlphadvantageAPI()
    i = 0
    for row in df
        symbol = row.Symbol
        if symbol === missing
            continue
        end

        if row.Sector == "n/a"
            continue
        end

        asset = Asset(symbol)
        SaveStockHistory(asset, outputsize="full", API=aa)

        i += 1
        if i > 100
            break
        end
        sleep(10)
    end
end

""" Fetches the average between open and close for a given date """
function FetchAverageAssetValue(asset::Asset, date::Union{DateTime,Date})
    global history
    date = Date(date)
    if isempty(history)
        history = LoadTop100History()
    end

    value = @from h in history[asset.symbol].history begin
            @where h[:timestamp] == date
            @select mean([h[:open], h[:adjusted_close]])
            @collect
    end

    value
end
