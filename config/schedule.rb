set :cron_log, "cron_log.log"

every 5.minutes do
  command "cd ~/Desktop/999parser ; ruby run.rb"
end
