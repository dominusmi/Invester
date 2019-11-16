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

SaveInvestment(_inv::Investment{LongInvestment}, pfId::Integer)         = SaveInvestment(_inv, pfId, "Long")
SaveInvestment(_inv::Investment{ShortInvestment}, pfId::Integer)        = SaveInvestment(_inv, pfId, "Short")
SaveInvestment(_inv::ClosedInvestment{LongInvestment}, pfId::Integer)   = SaveInvestment(_inv, pfId, "Long")
SaveInvestment(_inv::ClosedInvestment{ShortInvestment}, pfId::Integer)  = SaveInvestment(_inv, pfId, "Short")



function SavePortfolio(pf::MovingAveragePortfolio, name::String)
    conn = Connect()
    MySQL.Query(conn, """INSERT INTO Portfolios (name, type)
    	VALUES ('$name', 'MovingAveragePortfolio')
        ON DUPLICATE KEY UPDATE name = VALUES(name);""")

    res = MySQL.Query(conn, """SELECT id FROM Portfolios WHERE name='$name'""") |> DataFrame
    portfolioId = res[1,1]
    for _inv in pf.investments
        SaveInvestment(_inv, portfolioId)
    end
end
