using Test, Invester
using Dates

history = nothing
function runtests()
@testset "LoadTop100" begin
    history = LoadTop100History()
end

@testset "investment Basic Operations" begin
    asset = Asset("FB")
    investment = Investment{LongInvestment}(asset, 188.75, Dates.today())

    @test PotentialProfit(investment) ≈ 0.

    @test ClosedProfit(investment) ≈ 0.
    @test ClosedPercentage(investment) ≈ 0.

    closedInv = Close(investment, 190)
    @test ClosedProfit(closedInv) ≈ 1.25
    @test ClosedPercentage(closedInv) ≈ (190-188.75)/188.75 * 100

    investment = Investment{ShortInvestment}(asset, 188.75, Dates.today())

    @test PotentialProfit(investment) ≈ 0.

    @test ClosedProfit(investment) ≈ 0.
    @test ClosedPercentage(investment) ≈ 0.

    closedInv = Close(investment, 190)
    @test ClosedProfit(closedInv) ≈ -1.25
    @test ClosedPercentage(closedInv) ≈ (188.75-190)/188.75 * 100
end

end #runtests

runtests()
