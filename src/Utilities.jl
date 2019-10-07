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

function Base.iterate(iter::WallStreetDayIterator, currDay=iter.startDate)

    if currDay >= iter.endDate
       return nothing
    end

    next = NextWallStreetDay(currDay)

    return (currDay, next)
end

EndOf(date::Date) = DateTime(date, Dates.Time(23,59,59))

struct DayMonth
    day::Integer
    month::Integer
end
function DayMonth(d::Date)
    day = Day(d).value
    month = Month(d).value
    DayMonth(day,month)
end
const WallStreetHolidays = Set([DayMonth(1,1), DayMonth(21,1),DayMonth(18,2), DayMonth(19,4),
DayMonth(27,5), DayMonth(4,7), DayMonth(2,9), DayMonth(28,11),DayMonth(25,12)])

function IsWallStreetHoliday(date::Date)
    dow = dayofweek(date)
    if dow > 5
        return true
    end
    if DayMonth(date) in WallStreetHolidays
        return true
    end
    return false
end

function NextWallStreetDay(day::Date)
    dow = dayofweek(day)

    if dow < 5
        currReturn = day + Day(1)
    else
        currReturn = day + Day(8-dow)
    end

    # If the newly found working day is a holiday, recursively find the next one
    if DayMonth(currReturn) in WallStreetHolidays
        currReturn = NextWallStreetDay(currReturn)
    end
    return currReturn
end


Select(f::Function, a::AbstractArray) = a[findall(f,a)]

~(dt::GenericDate, d::GenericDate) = Date(dt) == Date(d)
