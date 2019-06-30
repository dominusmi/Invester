Format(api::API, endpoint::String) = api.base * endpoint
Format(api::AlphadvantageAPI, endpoint::String) = api.base * endpoint * "&apikey=" * api.key

function FetchSymbols(iex::IEXTradingAPI)
    endpoint = "/ref-data/symbols"
    JSON.Parse(Request(iex,endpoint))
end

function FetchHistory(api::AlphadvantageAPI, asset::Asset, method::String, outputsize::String; datatype=nothing)
    endpoint = "symbol=$(asset.symbol)&"
    endpoint *= "function=$method&"
    endpoint *= "outputsize=$outputsize"

    !isnothing(datatype) ? endpoint *= "&datatype=$datatype" : nothing

    Request(api, endpoint)
end

FetchWeeklyHistory(api::AlphadvantageAPI, asset::Asset, outputsize::String; datatype=nothing) =
    FetchHistory(api, asset, "TIME_SERIES_WEEKLY_ADJUSTED", outputsize, datatype=datatype)

FetchDailyHistory(api::AlphadvantageAPI, asset::Asset, outputsize::String; datatype=nothing) =
    FetchHistory(api, asset, "TIME_SERIES_DAILY_ADJUSTED", outputsize, datatype=datatype)



function Request(api::API, endpoint::String)
    url = Format(api, endpoint)
    println("Requesting $url")
    r = HTTP.request("GET", url)

    r.body
end
