using Invester
using DataFrames
using Dates
using HTTP
using CSV

function getAlreadySavedSymbols(path)::Set
    glob("*.csv", path)   |>
        x->basename.(x)                 |>
        x->[split(t,".")[1] for t in x] |>
        x->string.(x)                   |>
        Set
end

function SaveTop100CompaniesCSV()
    date = Dates.today()
    Top100CompaniesPath = Invester.BASE_PATH * "/resources/top100.tsv"
    api = AlphadvantageAPI()

    # Get 100 companies
    top100List = readtable(Top100CompaniesPath)

    # Make new directory to store info
    save_path = Invester.BASE_PATH * "/resources/BillionCompaniesStockHistory $date"
    alreadySaved = Set()
    if isdir(save_path)
        alreadySaved = getAlreadySavedSymbols(save_path)
    else
        mkdir(save_path)
    end

    companies_not_fetched = []

    # Loop to save each company history
    i = 0
    time_to_remove = 0.
    for company in top100List.Symbol[1:100]
        company in alreadySaved ? continue : nothing

        # Fetch company csv
        time_to_remove += @elapsed body = Invester.FetchDailyHistory(api, Asset(company), "full", datatype="csv")

        # Check it worked
        try
            CSV.File(body)
            open("$save_path/$company.csv", "w") do out
                write(out, body)
            end
        catch
            push!(companies_not_fetched, company)
        end

        # Wait due to API limits
        i += 1
        if i % 5 == 0
            println("Sleeping for $(61-time_to_remove)")
            sleep(61-time_to_remove)
            time_to_remove = 0
        end
    end
    companies_not_fetched
end

companies_not_fetched = SaveTop100CompaniesCSV()
