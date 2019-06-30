function LoadTop100History()
   assetHistories = Dict()
    for path in glob("*.csv", "resources/Top100Companies/")
        symbol = split( split(path, '/')[end], '.')[1]
        asset = Asset(String(symbol))

        @show "Loading $(symbol)"

        hist = loadtable(path, indexcols=["timestamp"])
        assetHistories[symbol] = hist
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
