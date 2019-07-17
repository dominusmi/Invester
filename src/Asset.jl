function AddFromDate(asset::AssetHistoryBuffer, date::String, dict::Dict)
    date = int.(split(date,"-"))
    date = Date(date...)

    push!(asset.dates, date)
    push!(asset.open, _dict["1. open"])
    push!(asset.high, _dict["2. high"])
    push!(asset.low, _dict["3. low"])
    push!(asset.close, _dict["4. close"])
    push!(asset.close_adjusted, _dict["5. adjusted close"])
    push!(asset.volume, _dict["6. volume"])
    push!(asset.dividend, _dict["7. dividend amount"])
    push!(asset.split_coef, _dict["8. split coefficient"])
end

function GetFromHistory(asset::AssetHistoryBuffer, history::Dict)
    for (date,value) in history
        AddFromDate(asset,date,value)
    end
    return AssetHistory(asset)
end

function SaveStockHistory(asset::Asset; outputsize="full", API::API = AlphadvantageAPI())

    r = FetchDailyHistory(API, asset, "full", datatype="csv")

    open("resources/$(asset.symbol).csv", "w+") do io
       write(io, r)
    end
end

Base.isequal(a1::Asset, a2::Asset) = a1.symbol == a2.symbol
