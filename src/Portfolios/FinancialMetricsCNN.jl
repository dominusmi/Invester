struct FinancialMetricsCNNPortfolio <: AbstractPortfolio
    investments::Array{<:AbstractInvestment}
    lowerClosePercentageThreshold::Number
    upperClosePercentageThreshold::Number
    maxInvestments::Integer
    longThreshold::Number
    closeThreshold::Number
    model::Chain
    modelName::AbstractString
end

function FinancialMetricsCNNPortfolio(;
    investments::Array{<:AbstractInvestment} = Array{AbstractInvestment,1}(),
    lowerClosePercentageThreshold::Number = -0.06,
    upperClosePercentageThreshold::Number = 0.02,
    maxInvestments::Integer = 1e4,
    longThreshold::Number = 0.5,
    closeThreshold::Number = 0.5,
    modelName::AbstractString = "CNN3C3D58p")

    global Using_GPU

    model_type = include_string(Invester, modelName)
    model = LoadModel(model_type)

    model = USING_GPU ? gpu(model) : model

    FinancialMetricsCNNPortfolio(investments, lowerClosePercentageThreshold, upperClosePercentageThreshold,
        maxInvestments, longThreshold, closeThreshold, model, modelName)
end


const FMCNN_EPISODE_LENGTH = 40
const FMCNN_ANALYSED_LENGTH = 20
const FMCNN_FEATURES = [:open, :adjusted_close, :low, :high, :volume]
const FMCNN_WINDOW = 10

function ComputeEngineeredEpisode(episode)

    analysed_range = (size(episode,1)-FMCNN_ANALYSED_LENGTH+1):size(episode,1)
    normaliser = episode[analysed_range[1],:]'

    # 8 is the number of columns: 5 main and 3 metrics
    engineered_episode = zeros(FMCNN_ANALYSED_LENGTH, 8)

    # This would later break due to division by zero
    if any(normaliser.==0.0)
        return nothing
    end
    episode = episode ./ normaliser
    engineered_episode[:,1:5] = episode[analysed_range,:]

    adrs = zeros(size(analysed_range,1))
    advs = zeros(size(analysed_range,1))
    ∇obvs = zeros(size(analysed_range,1))
    for (j,range) in enumerate(analysed_range)
        ∇obvs[j] = Invester.∇OBV(episode[1:range,2], episode[1:range,5], FMCNN_WINDOW)
        adrs[j] = Invester.AdvanceDeclineRatio(episode[range-1:range],1)
        advs[j] = Invester.AdvanceDeclineVolume(episode[range-1:range],1)
    end
    engineered_episode[:,6] = ∇obvs
    engineered_episode[:,7] = adrs
    engineered_episode[:,8] = advs

    return engineered_episode
end

function GenerateCurrentEpisode(asset::Asset, date::Date = Dates.today())
    global USING_GPU

    # Take more days to avoid bad surprises, overhead minimal
    episode = FetchAssetHistory(asset, date, daysInHistory = 2*FMCNN_EPISODE_LENGTH)

    # Sanity check
    if (size(episode,1) <= FMCNN_EPISODE_LENGTH) return nothing end

    # Convert "episode" data into matrix
    episode = convert(Matrix, episode[end-FMCNN_EPISODE_LENGTH:end, FMCNN_FEATURES])
    return episode
end

function ComputeΔPrediction(pf::FinancialMetricsCNNPortfolio, engineered_episode)
    engineered_episode = USING_GPU ? gpu(engineered_episode) : engineered_episode

    reshape_size = (FMCNN_ANALYSED_LENGTH, 8, 1, 1)
    prediction = Tracker.data( pf.model(reshape(engineered_episode, reshape_size))[1] )

    Δprediction = prediction - engineered_episode[end,2]

    Δprediction = USING_GPU ? cpu(Δprediction) : Δprediction
    return Δprediction
end

function LongConfidence(asset::Asset, pf::FinancialMetricsCNNPortfolio, date::Date = Dates.today())

    episode = GenerateCurrentEpisode(asset,date)
    if (episode == nothing) return 0 end

    # Gets episode with all metrics
    engineered_episode = ComputeEngineeredEpisode(episode)

    Δprediction = ComputeΔPrediction(pf, engineered_episode)

    # If Δprediction <0, obviously no long. If greater than 0.05, probably anomaly.
    if Δprediction < 0 || Δprediction > 0.05
        return 0
    end
    confidence = 0.5 + 10*Δprediction
    return confidence
end


# Close confidence very basic
function CloseConfidence(investment::Investment, pf::FinancialMetricsCNNPortfolio,
                         date::Date = Dates.today())



    currentValue = FetchCloseAssetValue(investment.asset, date)
    # if (currentValue == nothing) return 0 end

    episode = GenerateCurrentEpisode(investment.asset,date)

    # Gets episode with all metrics
    engineered_episode = ComputeEngineeredEpisode(episode)
    if (engineered_episode == nothing) return 0  end

    Δprediction = ComputeΔPrediction(pf, engineered_episode)

    pot = PotentialProfitPercentage(investment, currentValue)

    if Δprediction < -0.01 && pot > 0
        return 1
    elseif pot > pf.upperClosePercentageThreshold
        return 1
    elseif pot < pf.lowerClosePercentageThreshold
        return 1
    end

    return 0

    # history = CheckLoadHistory()
    # asset = investment.asset
    #
    # currentValue = FetchCloseAssetValue(asset, date)
    # if currentValue == nothing
    #     return 0
    # end
    #
    # pot = PotentialProfitPercentage(investment, currentValue)
    #
    # assetHistory = FetchOpenCloseAssetHistory(asset, date; daysInHistory=365)
    #
    # minimumSequenceLength = 3 * 3
    # if size(assetHistory,1) < minimumSequenceLength+1
    #     return 0
    # end
    #
    # # Calculate moving averages over last days (to calculate the linear trend)
    # MAs = MovingAverage(assetHistory[(end-minimumSequenceLength-1):end,:adjusted_close], 3)
    #
    # # Calculate trend of moving average
    # subArrayMAs = MAs[(end-3): end]
    # trend = LinearTrend(subArrayMAs)
    #
    #
    # if pot > UpperClosePercentageThreshold(pf) || pot < LowerClosePercentageThreshold(pf) || (pot > 0 && trend < 0)
    #     return 1
    # end
    # return 0
end

function Serialise(pf::FinancialMetricsCNNPortfolio)::AbstractString
    fn = fieldnames(typeof(pf))
    fields = Set(fn)
    delete!(fields, :investments)
    delete!(fields, :model)

    serialised = Dict()
    for field in fields
        serialised[field] = getfield(pf, field)
    end
    "$serialised"
end
