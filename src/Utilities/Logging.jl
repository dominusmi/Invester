LOGGING_PATH = BASE_PATH * "/Logs"
JOB_LOG_PATH = LOGGING_PATH * "/jobs.txt"


function LogJobError(message)
    date = Dates.now()
    open(JOB_LOG_PATH, "a") do f
           write(f, "ERROR $date: " * message * "\n")
    end;
end
