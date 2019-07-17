using Test, Invester
using Dates

history = nothing
const DefaultDate = DateTime(Date(2019,6,18))
const CloseDate = DateTime(Date(2019,6,25))

@testset "LoadTop100" begin
    global history
    history = LoadTop100History()
    @test history != nothing
end

@testset "investment Basic Operations" begin

    global history

    @assert history != nothing

    asset = Asset("FB")
    investment = Investment{LongInvestment}(asset, 188.75, DefaultDate)

    @test PotentialProfit(investment, 188.75) ≈ 0.

    @test ClosedProfit(investment) ≈ 0.
    @test ClosedPercentage(investment) ≈ 0.

    closedInv = Close(investment, 190)
    @test ClosedProfit(closedInv) ≈ 1.25
    @test ClosedPercentage(closedInv) ≈ (190-188.75)/188.75 * 100

    investment = Investment{ShortInvestment}(asset, 188.75, DefaultDate)

    @test typeof(investment) == Investment{ShortInvestment}

    @test PotentialProfit(investment, 190) ≈ -1.25

    @test ClosedProfit(investment) ≈ 0.
    @test ClosedPercentage(investment) ≈ 0.

    closedInv = Close(investment, 190)
    @test typeof(closedInv) == ClosedInvestment{ShortInvestment}

    @test ClosedProfit(closedInv) ≈ -1.25
    @test ClosedPercentage(closedInv) ≈ (188.75-190)/188.75 * 100
end

@testset "Fetching asset value" begin
    asset = Asset("FB")
    investment = Investment{LongInvestment}(asset, 188.75, DefaultDate)
    pot = PotentialProfit(investment, CloseDate)
    @test pot == 190.86 - 188.75
end

@testset "Portfolio basic operations" begin

    pf = Portfolio()
    @test typeof(pf) == Portfolio

    Add!(pf, Investment{LongInvestment}(Asset("FB"), 188.75, DefaultDate))
    Add!(pf, Investment{ShortInvestment}(Asset("MSFT"), 120., DefaultDate))

    @test size(pf.investments,1) == 2

    pot = PotentialProfit(pf, CloseDate)
    @test ClosedProfit(pf) ≈ 0.
    @test pot ≈ (190.86 - 188.75) + (120-135.34)

    @test size(OpenInvestments(pf, Asset("FB")),1) == 1

    Close!(pf, pf.investments[1], 190, CloseDate)

    @test ClosedProfit(pf) ≈ 1.25
    @test PotentialProfit(pf, CloseDate) == (120-135.34)

    @test size(OpenInvestments(pf, Asset("FB")),1) == 0

end


@testset "DataAccess API" begin
    @assert history != nothing
    asset = Asset("FB")

    @test FetchAverageAssetValue(asset, DefaultDate) ≈ 191.235

    intervalHist = FetchAverageAssetValue(asset, DefaultDate, CloseDate)
    @test typeof(intervalHist) <: Array{<:AbstractFloat,1}
    @test size(intervalHist,1) == 6
end


@testset "Analysis" begin
    @test MovingAverage( collect(1.0:7.0) , 7) ≈ 5.0
    @test MovingAverage( collect(1.0:7.0) , 4) ≈ 6.0
end
