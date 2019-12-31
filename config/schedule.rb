# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/whenever.log'

every :day, at: '1am' do
  rake 'om:update_parsers'
end

every :day, at: '4am' do
  rake 'om:update_sources'
end

every 5.minutes do
  rake 'om:update_feeds'
end

every :day, at: '9am' do
  rake 'om:daily_reports'
end
