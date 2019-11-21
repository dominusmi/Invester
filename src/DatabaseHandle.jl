function Connect()
    global DbConnection
    if DbConnection == nothing
        ci = JSON.parsefile(Invester.CONFIG_PATH * "/appconfig.json")["Database"]
        DbConnection = MySQL.connect(ci["Server"], ci["Username"], ci["Password"], db = "Invester")
    end
    return DbConnection
end

function SaveInvestment(_inv::Investment, pfId::Integer, type::String)
    conn = Connect()
    MySQL.Query(conn, """INSERT INTO Investments (asset, valueOpen, dateOpen, uuid, type, invested, portfolioId)
    	VALUES ('$(_inv.asset.symbol)', $(_inv.value), '$(Dates.format(_inv.dateOpen, "yyyy-mm-dd HH:MM:SS"))',
    	'$(_inv.uuid)', '$type', $(_inv.invested), $pfId) ON DUPLICATE KEY UPDATE asset = VALUES(asset);""")
end
function SaveInvestment(_inv::ClosedInvestment, pfId::Integer, type::String)
    conn = Connect()
    MySQL.Query(conn, """INSERT INTO Investments (asset, valueOpen, valueClose, dateOpen, dateClose, uuid, type, invested, portfolioId)
    	VALUES ('$(_inv.asset.symbol)', $(_inv.valueOpen), $(_inv.valueClose), '$(Dates.format(_inv.dateOpen, "yyyy-mm-dd HH:MM:SS"))',
    	'$(Dates.format(_inv.dateClose, "yyyy-mm-dd HH:MM:SS"))', '$(_inv.uuid)', '$type', $(_inv.invested), $pfId)
        ON DUPLICATE KEY UPDATE asset = VALUES(asset);""")
end

SaveInvestment(_inv::Investment{LongInvestment}, pfId::Integer)         = SaveInvestment(_inv, pfId, "LongInvestment")
SaveInvestment(_inv::Investment{ShortInvestment}, pfId::Integer)        = SaveInvestment(_inv, pfId, "ShortInvestment")
SaveInvestment(_inv::ClosedInvestment{LongInvestment}, pfId::Integer)   = SaveInvestment(_inv, pfId, "LongInvestment")
SaveInvestment(_inv::ClosedInvestment{ShortInvestment}, pfId::Integer)  = SaveInvestment(_inv, pfId, "ShortInvestment")

function DeletePortfolioInvestments(pfId::Integer)
    conn = Connect()
    query = """DELETE FROM Investments WHERE portfolioId=$pfId;"""
    MySQL.Query(conn, query)
end

function DeletePortfolioInvestments(pfName::AbstractString)
    conn = Connect()
    pfDf = MySQL.Query(conn, """SELECT * FROM Portfolios WHERE name='$pfName'""") |> DataFrame
    pfId = pfDf[1,:id]
    query = """DELETE FROM Investments WHERE portfolioId=$pfId;"""
    MySQL.Query(conn, query)
end

function SavePortfolio(pf::MovingAveragePortfolio, name::String)

    netClosedPercentageEquity = ClosedProfitPercentage(pf)
    potentialProfitPercentage = PotentialProfitPercentage(pf)

    conn = Connect()
    query = """INSERT INTO Portfolios (name, type, kwargs, NetClosedPercentageEquity, PotentialPercentageEquity)
    	VALUES ('$name', 'MovingAveragePortfolio','$(Serialise(pf))', $netClosedPercentageEquity, $potentialProfitPercentage)
        ON DUPLICATE KEY UPDATE
        kwargs = VALUES(kwargs),
        NetClosedPercentageEquity=VALUES(NetClosedPercentageEquity),
        PotentialPercentageEquity=VALUES(PotentialPercentageEquity);"""
    MySQL.Query(conn, query)

    res = MySQL.Query(conn, """SELECT id FROM Portfolios WHERE name='$name';""") |> DataFrame
    portfolioId = res[1,1]
    for _inv in pf.investments
        SaveInvestment(_inv, portfolioId)
    end
end

function LoadInvestmentFromDf(invtype::Type{Investment{T}}, df::DataFrameRow) where T <: InvestmentType
    invtype( Asset(df[:asset]), df[:valueOpen], df[:invested], df[:dateOpen], Base.UUID(df[:uuid]) )
end
function LoadInvestmentFromDf(invtype::Type{ClosedInvestment{T}}, df::DataFrameRow) where T <: InvestmentType
    invtype( Asset(df[:asset]), df[:valueOpen], df[:valueClose], df[:invested], df[:dateOpen], df[:dateClose], Base.UUID(df[:uuid]) )
end

function LoadPortfolio(name::String)
    conn = Connect()
    pfDf = MySQL.Query(conn, """SELECT * FROM Portfolios WHERE name='$name'""") |> DataFrame
    pf = Deserialise(AbstractPortfolio, pfDf[1,:type], pfDf[1,:kwargs])

    invsDf = MySQL.Query(conn, """SELECT * FROM Investments WHERE portfolioId=$(pfDf[1,:id])""") |> DataFrame
    for _invRow in eachrow(invsDf)
        type = include_string(Invester, _invRow[:type])
        open = ismissing(_invRow[:dateClose])
        invtype = open ? Investment{type} : ClosedInvestment{type}

        _inv = LoadInvestmentFromDf(invtype, _invRow)
        Add!(pf, _inv)
    end
    pf
end
