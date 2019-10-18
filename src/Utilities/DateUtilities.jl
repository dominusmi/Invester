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

    if currDay >= iter.endDate || iter.currIteration >= iter.intervalLength
       return nothing
    end

    next = NextWallStreetDay(currDay)
    iter.currIteration += 1
    return (currDay, next)
end
Base.IteratorSize(itr::WallStreetDayIterator) = Base.SizeUnknown()

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

"""
Get asset data during a interval specified by first date and number of working days
"""
function GetIntervalData(asset::Asset, initDate::Date, intervalLength::Integer)::DataFrame
    endDate = collect(Invester.WallStreetDayIterator(initDate, intervalLength))[end]
    data = @from h in history[asset.symbol].history begin
        # We pick more than the actual interval length to account for unforseen reasons for closed days
        @where h[:timestamp] >= initDate && h[:timestamp] <= endDate+Day(5)
        @select h
        @collect DataFrame
        end;
    data
end

""" Generic date day comparator """
~(dt::GenericDate, d::GenericDate) = Date(dt) == Date(d)
