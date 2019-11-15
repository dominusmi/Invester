
function Connect()
    global conn
    if conn == nothing
        conn = MySQL.connect("127.0.0.1", "ed", "pgsta3443", db = "Invester")
    end
end

function SaveInvestment(_inv::Investment{LongInvestment})
    global conn
    MySQL.Query(conn, """INSERT INTO Investments (asset, value, dateOpen, uuid, type, invested)
    	VALUES ('$(_inv.asset.symbol)', $(_inv.value), '$(Dates.format(_inv.dateOpen, "yyyy-mm-dd HH:MM:SS"))',
    	'$(_inv.uuid)', 'Long', $(_inv.invested)) ON DUPLICATE KEY UPDATE asset = VALUES(asset);""")
end
