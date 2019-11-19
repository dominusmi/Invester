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

function SaveTop100CompaniesCSV(;update_only=false, max_time_to_wait = 65)
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
    LogJobInfo("Started fetching stock prices")
    i = 0
    time_to_remove = 0.
    for company in top100List.Symbol[1:100]
        company in alreadySaved ? continue : nothing

        # Fetch company csv
        time_to_remove += @elapsed body = Invester.FetchDailyHistory(api, Asset(company), "full", datatype="csv")

        # Check if there was an API limit error
        if length(body) < 250
            LogJobError("Reached API limit with $company - waiting")
            push!(companies_not_fetched, company)
            time_to_remove = 0
            i=0
        else
            # Check it worked
            try
                open("$newDirectoryPath/$company.csv", "w") do out
                    write(out, body)
                end
            catch e
                LogJobError("Failed to load $company - $e")
                push!(companies_not_fetched, company)
            end

            # Wait due to API limits
            i += 1
        end
        if i % 5 == 0
            LogJobInfo("Sleeping for $(max_time_to_wait-time_to_remove)")
            sleep(max_time_to_wait-time_to_remove)
            time_to_remove = 0
        end
    end
    companies_not_fetched
end

update_only = isempty(ARGS) ? false : true

# Retries at most three times to fetch company information
for i in 1:3
    companies_not_fetched = SaveTop100CompaniesCSV(; update_only=update_only)

    # If all companies fetched, success
    if isempty(companies_not_fetched)
        break
    else
        # If some companies were not fetched, and wait extra time for safety
        LogJobInfo("Did not manage to retrieve $companies_not_fetched. Re-running for $i time.")
        SaveTop100CompaniesCSV(;update_only=true, max_time_to_wait = 65 + 30*i)
    end
end
if isempty(companies_not_fetched)
    LogJobInfo("Succesfully finished updating CSVs")
else
    LogJobInfo("Did not manage to retrieve $companies_not_fetched. Ending process.")
end
