LOGGING_PATH = BASE_PATH * "/Logs"
JOB_LOG_PATH = LOGGING_PATH * "/jobs.txt"
BASE_LOG_PATH = LOGGING_PATH * "/log.txt"
ERROR_LOG_PATH = LOGGING_PATH * "/error.txt"

function LogJobInfo(message; print=true)
    date = Dates.now()
    open(JOB_LOG_PATH, "a") do f
           write(f, "[INFO] $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end

function LogJobError(message; print=true)
    date = Dates.now()
    open(JOB_LOG_PATH, "a") do f
           write(f, "[ERROR] $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end

function LogInfo(message; print=true)
    date = Dates.now()
    open(BASE_LOG_PATH, "a") do f
           write(f, "[INFO] $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end

function LogWarn(message; print=true)
    date = Dates.now()
    open(BASE_LOG_PATH, "a") do f
           write(f, "[WARN] $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end

function LogError(message; print=true)
    date = Dates.now()
    open(ERROR_LOG_PATH, "a") do f
           write(f, "[ERROR] $date: " * message * "\n")
    end;
    print ? println(message) : nothing
end
