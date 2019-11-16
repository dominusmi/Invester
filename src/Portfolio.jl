""" Get all open investments """
function OpenInvestments(pf::AbstractPortfolio)
    idxs = findall(x-> isOpenInvestment(x), pf.investments)
    pf.investments[idxs]
end

""" Get all open investments of a given asset """
function OpenInvestments(pf::AbstractPortfolio, a::Asset)
    idxs = findall(x-> isOpenInvestment(x) && x.asset == a, pf.investments)
    pf.investments[idxs]
end

""" Get all closed investments """
function ClosedInvestments(pf::AbstractPortfolio)
    idxs = findall(x-> isClosedInvestment(x), pf.investments)
    pf.investments[idxs]
end

""" Get all closed investments of a given asset """
function ClosedInvestments(pf::AbstractPortfolio, a::Asset)
    idxs = findall(x-> isClosedInvestment(x) && x.asset == a, pf.investments)
    pf.investments[idxs]
end

""" Get all investments opened on date """
function InvestmentsOpenedOn(pf::AbstractPortfolio, date::GenericDate)
    Invester.Select(x->x.dateOpen ~ date, pf.investments)
end

""" Get all investments closed on date """
function InvestmentsClosedOn(pf::AbstractPortfolio, date::GenericDate)
    Invester.Select(x->x.dateClose ~ date, ClosedInvestments(pf))
end

""" Get all investments which were open at date """
function InvestmentsOpenOn(pf::AbstractPortfolio, date::GenericDate; includeOpenedOn=false, includeClosedOn=false)
    inInterval = Invester.Select(x->isOpen(x, date), pf.investments)
    if includeOpenedOn
        inInterval = vcat(inInterval, Invester.Select(x->x.dateOpen ~ date, pf.investments) )
    end
    if includeClosedOn
        inInterval = vcat(inInterval, Invester.Select(x->x.dateClose ~ date, ClosedInvestments(pf)) )
    end
    inInterval
end


function PotentialProfit(pf::AbstractPortfolio, date::GenericDate = Dates.today())
    date = Date(date)
    total = 0.
    for inv in OpenInvestments(pf)
        total += PotentialProfit(inv, date)
    end
    total
end

function PotentialProfitPercentage(pf::AbstractPortfolio, date::GenericDate = Dates.today())
    date = Date(date)
    total = 0.
    for inv in OpenInvestments(pf)
        total += PotentialProfitPercentage(inv, date) / inv.invested
    end
    total
end

function ClosedProfit(pf::AbstractPortfolio)
    total = 0.
    for inv in ClosedInvestments(pf)
        total += ClosedProfit(inv)
    end
    total
end

function ClosedProfitPercentage(pf::AbstractPortfolio)
    total = 0.
    for inv in ClosedInvestments(pf)
        total += ClosedProfitPercentage(inv)
    end
    total
end


LowerClosePercentageThreshold(pf::AbstractPortfolio) = pf.lowerClosePercentageThreshold
UpperClosePercentageThreshold(pf::AbstractPortfolio) = pf.upperClosePercentageThreshold
MaxNumberOfInvestment(pf::AbstractPortfolio) = pf.maxInvestments
LongThreshold(pf::AbstractPortfolio) = pf.longThreshold
CloseThreshold(pf::AbstractPortfolio) = pf.closeThreshold


function AverageInvestmentLength(pf::AbstractPortfolio)
    closedInvs = ClosedInvestments(pf)
    mean(Duration.(closedInvs))
end

function AveragePercentageProfit(pf::AbstractPortfolio)
    closedInvs = ClosedInvestments(pf)
    mean(ClosedProfitPercentage.(closedInvs))
end
