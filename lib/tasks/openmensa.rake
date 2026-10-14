# frozen_string_literal: true

namespace :feeds do
  desc "Schedule fetch jobs for all active feeds"
  task schedule: :environment do
    ScheduleFeedsJob.perform_now
  end
end

namespace :parsers do
  desc "Fetch parser index lists"
  task update: :environment do
    OpenMensa::UpdateParsersTask.new.do
  end
end
