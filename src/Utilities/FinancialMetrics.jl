#region Market indicators
function AdvanceDeclineRatio(history::Dict{Symbol,AssetHistory}, date::GenericDate, interval::Integer=2)
    countADR = 0
    sumADR = 0
    nSymbols = length(history)
    for (symbol,assetHistory) in history
        try
            adr = AdvanceDeclineRatio(assetHistory.asset, date, interval)
            countADR += adr > 1
            sumADR += adr
        catch e
            if isa(e,BoundsError)
                # Caught when looking at history of asset which wasn't yet public
                nSymbols -= 1
            else rethrow(e)
            end
        end
    end
    return (float(countADR)/nSymbols, float(sumADR)/nSymbols)
end
function AdvanceDeclineVolume(history::Dict{Symbol,AssetHistory}, date::GenericDate, interval::Integer=2)
    countADV = 0
    sumADV = 0
    nSymbols = length(history)
    for (symbol,assetHistory) in history
        try
            adv = AdvanceDeclineVolume(assetHistory.asset, date, interval)
            countADV += adv > 1
            sumADV += adv
        catch e
            if isa(e,BoundsError)
                # Caught when looking at history of asset which wasn't yet public
                nSymbols -= 1
            else rethrow(e)
            end
        end
    end
    return (float(countADV)/nSymbols, float(sumADV)/nSymbols)
end
#endregion

#region Asset indicators
""" Computes the advance decline ratio of an asset: (close value at date) / (close value x days earlier) """
function AdvanceDeclineRatio(asset::Asset, date::GenericDate, interval::Integer=2)::AbstractFloat
    _end = FetchCloseAssetValue(asset, date)
    _ini = FetchCloseAssetValue(asset, date-Dates.Day(interval))
   return _end / _ini
end

function AdvanceDeclineVolume(asset::Asset, date::GenericDate, interval::Integer=2)::AbstractFloat
    _end = FetchAssetVolume(asset, date)
    _ini = FetchAssetVolume(asset, date-Dates.Day(interval))
   return _end / _ini
end

""" On balance volume divergence"""
function ∇OBV(asset::Asset, date::GenericDate, window::Integer=14)
    hist = FetchAssetHistory(asset,date,daysInHistory=3*window)
    OBV(hist[!,:adjusted_close], hist[!,:volume], window)
end

function ∇OBV(values::AbstractArray{<:Number}, volumes::AbstractArray{<:Number}, window::Integer=14)
    MAs = MovingAverage(values, window)[end-window:end]
    MAs = (MAs.-minimum(MAs)) / (maximum(MAs)-minimum(MAs))
    _coefClose = LinearTrend(MAs)

    VMAs = MovingAverage(volumes, window)[end-window:end]
    VMAs = (VMAs.-minimum(VMAs)) / (maximum(VMAs)-minimum(VMAs))
    _coefVolume = LinearTrend(VMAs)

    if _coefClose * _coefVolume > 0
        # i.e. if they're both positive or negative
        return 0
    else
        return abs(_coefClose-_coefVolume)
    end
end

""" Current Money Flow Volume """
CMFV(Pl::Number, Ph::Number, Pc::Number, V::Number) = ( (Pc-Pl)-(Ph-Pc) ) / (Ph-Pl) * V

"""
    Returns the  Accumulation Distribution line values. The window is the interval to compute the values on: end-window to end of array
"""
function ADValues(asset::Asset, date::GenericDate, window::Integer=5)
    hist = FetchAssetHistory(asset, date, daysInHistory=3*window)
    ADLine(hist[!,:low], hist[!,:high], hist[!,:adjusted_close], hist[!,:volume], window)
end

function ADValues(lows::AbstractArray{<:Number}, highs::AbstractArray{<:Number}, closings::AbstractArray{<:Number},
                volumes::AbstractArray{<:Number}, window::Integer=5)

    AD = zeros(window)
    AD[1] = CMFV(lows[end-window+1], highs[end-window+1], closings[end-window+1], volumes[end-window+1])
    for i in 2:window
        AD[i] = AD[i-1] + CMFV(lows[end-window+i], highs[end-window+i], closings[end-window+i], volumes[end-window+i])
    end
    return AD
end
#endregion
