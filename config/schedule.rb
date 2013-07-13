set :cron_log, "cron_log.log"

every 2.minutes do
  command "ruby ~/Desktop/999parser/run.rb"
end
