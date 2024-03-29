"""
    Generates random time series episodes of specified length
    Returns two arrays, episodes and predictions / future.
    Both are of shape m x n, where m is the length of each episode,
    and n the number of episodes.
"""
function GenerateTimeSeriesEpisodes(
    data::Union{Array{<:Number}, DataFrame}, episodeLength::Integer, predictLength::Integer, cols::Integer=1;
        overlap=false, n_eps = nothing)

    fullEpisodeLength = episodeLength + predictLength

    if n_eps == nothing
        n_eps = Int(floor(size(data,1)/fullEpisodeLength))-1
    end
    interval = size(data,1)-fullEpisodeLength

    episodes = zeros(episodeLength, n_eps)
    predicts = zeros(predictLength, n_eps)

    for i in 1:n_eps
        if overlap
            idx = rand(1:interval)
        else
            idx = i * episodeLength
        end

        eps_begin = idx
        eps_end = idx+episodeLength-1
        prd_begin = eps_end+1
        prd_end = prd_begin+predictLength-1
        episodes[:,i] = data[eps_begin:eps_end, cols]
        predicts[:,i] = data[prd_begin:prd_end, cols]
    end
    episodes, predicts
end

"""
    Generates random time series episodes of specified length
    Returns two matrices, episodes and predictions / future.
    Shape: m x f x n
    m: episode length
    f: number of features
    n: number of episodes
"""
function GenerateTimeSeriesEpisodes(
        data::Union{Array{<:Number}, DataFrame}, episodeLength::Integer, predictLength::Integer, cols::AbstractArray=1:size(data,2);
        overlap::Bool=false, n_eps = nothing)

    fullEpisodeLength = episodeLength + predictLength

    if n_eps == nothing
        n_eps = Int(floor(size(data,1)/fullEpisodeLength))-1
    end
    interval = size(data,1)-fullEpisodeLength

    episodes = zeros(episodeLength, size(cols,1), n_eps)
    predicts = zeros(predictLength, size(cols,1), n_eps)

    for i in 1:n_eps
        if overlap
            idx = rand(1:interval)
        else
            idx = i * episodeLength
        end

        eps_begin = idx
        eps_end = idx+episodeLength-1
        prd_begin = eps_end+1
        prd_end = prd_begin+predictLength-1
        episodes[:,:,i] = convert(Matrix, data[eps_begin:eps_end, cols])
        predicts[:,:,i] = convert(Matrix, data[prd_begin:prd_end, cols])
    end
    episodes, predicts
end

" divides episodes and predictions by the first value of the episode "
function NormaliseEpisode(episodes::AbstractArray{<:Number}, predictions::Array{<:Number})
    episodes .\ episodes[1,:]', predictions .\ episodes[1,:]'
end
