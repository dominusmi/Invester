function LoadTop100History()::Dict{Symbol, AssetHistory}
    assetHistories = Dict{Symbol, AssetHistory}()
    count = 0
    for path in glob("*.csv", dirname(pathof(Invester))*"/resources/Top100Companies/")
        symbol = split( split(path, '/')[end], '.')[1]
        asset = Asset(String(symbol))

        hist = loadtable(path, indexcols=["timestamp"])
        assetHistory = AssetHistory(asset,hist)
        assetHistories[asset.symbol] = assetHistory
        count += 1
    end
    println("Loaded $count stocks")
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

mutable struct DayOfWeekIterator
    startDate::Date
    length::Integer
end
DayOfWeekIterator(s::Date, e::Date) = DayOfWeekIterator(s, (e-s).value)

function Base.iterate(iter::DayOfWeekIterator, state=(iter.startDate, 0))
    element, count = state

    if count >= iter.length
       return nothing
    end

    if dayofweek(element) == 6
        return (element+Day(2), (element + Day(3), count+1))
    end

    if dayofweek(element) == 7
        return (element+Day(1), (element + Day(2), count+1))
    end

    return (element, (element + Day(1), count + 1))
end
