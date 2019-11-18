using Invester
using Invester: LogJobInfo, LogJobError
using DataFrames
using Dates
using HTTP
using CSV
using Glob

function getAlreadySavedSymbols(path)::Set
    glob("*.csv", path)   |>
        x->basename.(x)                 |>
        x->[split(t,".")[1] for t in x] |>
        x->string.(x)                   |>
        Set
end

function SaveTop100CompaniesCSV(;update_only=false)
    date = Dates.today()
    Top100CompaniesPath = Invester.BASE_PATH * "/resources/top100.tsv"
    api = AlphadvantageAPI()

    update_only ? LogJobInfo("Running update mode") : LogJobInfo("Running replace mode")

    # Get 100 companies
    top100List = readtable(Top100CompaniesPath)

    # Rename current folder
    oldDirectoryPath = Invester.BASE_PATH * "/resources/Top100CompaniesOld"
    newDirectoryPath = Invester.BASE_PATH * "/resources/Top100Companies"

    # Remove old directory and rename new if they exist
    if !update_only
        if isdir(oldDirectoryPath)
            LogJobInfo("Removing old directory")
            run(`rm -r $oldDirectoryPath`)
        end
        if isdir(newDirectoryPath)
            LogJobInfo("Renaming current directory")
            run(`mv $newDirectoryPath $oldDirectoryPath`)
        end
    end

    # Make new directory to store info
    alreadySaved = Set()
    if isdir(newDirectoryPath)
        alreadySaved = getAlreadySavedSymbols(newDirectoryPath)
    else
        mkdir(newDirectoryPath)
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
            open("$newDirectoryPath/$company.csv", "w") do out
                write(out, body)
            end
        catch e
            LogJobError("Failed to load $company - $e")
            push!(companies_not_fetched, company)
        end

        # Wait due to API limits
        i += 1
        if i % 5 == 0
            println("Sleeping for $(65-time_to_remove)")
            sleep(65-time_to_remove)
            time_to_remove = 0
        end
    end
    companies_not_fetched
end

update_only = isempty(ARGS) ? false : true
companies_not_fetched = SaveTop100CompaniesCSV(; update_only=update_only)
