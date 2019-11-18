LOGGING_PATH = BASE_PATH * "/Logs"
JOB_LOG_PATH = LOGGING_PATH * "/jobs.txt"

function LogJobInfo(message; print=true)
    date = Dates.now()
    open(JOB_LOG_PATH, "a") do f
           write(f, "INFO $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end

function LogJobError(message; print=true)
    date = Dates.now()
    open(JOB_LOG_PATH, "a") do f
           write(f, "ERROR $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end
