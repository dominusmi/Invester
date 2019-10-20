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

function FetchCloseAssetsValueDictionary(assets::Array{Asset,1}, date::GenericDate)
    marketCloseValuesOnDate = Invester.FetchCloseAssetValue.(assets,date)
    asset2MarketPrice = Dict()
    for i in 1:size(marketCloseValuesOnDate,1)
        asset2MarketPrice[assets[i]] = marketCloseValuesOnDate[i]
    end
    asset2MarketPrice
end

"""
Get asset data during a interval specified by first date and number of working days
"""
function GetIntervalData(asset::Asset, initDate::Date, intervalLength::Integer)::DataFrame
    endDate = collect(Invester.WallStreetDayIterator(initDate, intervalLength))[end]
    data = @from h in history[asset.symbol].history begin
        # We pick more than the actual interval length to account for unforseen reasons for closed days
        @where h[:timestamp] >= initDate && h[:timestamp] <= endDate+Day(20)
        @select h
        @collect DataFrame
        end;
    data
end

" Makes a Flux compatible minibatch out of arrays"
function make_minibatch(X, Y, idxs)
    batch = Array{Tuple}(undef, length(idxs))
    for (i,idx) in enumerate(idxs)
       batch[i] = (reshape(trainX[:,idx], (size(trainX,1),1,1,1)), Y[:,idx])
    end
    batch
end

Select(f::Function, a::AbstractArray) = a[findall(f,a)]
