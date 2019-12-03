abstract type CNN3C3D58p end
function LoadModel(_::Type{CNN3C3D58p})
    model = Chain(
        Conv((3, 8), 1=>32, pad=(2,2), relu),
        MaxPool((2,2)),

        Conv((2,2), 32=>64, pad=(1,1), relu),
        MaxPool((2,2)),

        Conv((2,2), 64=>128, pad=(1,1), relu),
        MaxPool((2,2)),

        x -> reshape(x, :, size(x, 4)),
        Dense(384, 40, leakyrelu),
        Dense(40,10, leakyrelu),
        Dense(10,1)
    )
    prms = BSON.load( joinpath(dirname(@__FILE__), "CNN3C3D58p.bson") )[:prms]
    Flux.loadparams!(model,prms)
    return model
end
