"""
    Generates random time series episodes of specified length
    Returns two arrays, episodes and predictions / future.
    Both are of shape m x n, where m is the length of each episode,
    and n the number of episodes.
"""
function GenerateTimeSeriesEpisodes(data::Union{Array{<:Number}, DataFrame}, episodeLength, predictLength;
        overlap=false, cols=1:size(data,2), n_eps = nothing)

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

" divides episodes and predictions by the first value of the episode "
function NormaliseEpisode(episodes::Array{<:Number}, predictions::Array{<:Number})
    episodes .\ episodes[1,:]', predictions .\ episodes[1,:]'
end
