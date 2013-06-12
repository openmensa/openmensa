namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Rails.logger.info "[#{Time.zone.now}] Fetch canteen data..."
    date = Time.zone.now.to_date
    hour = Time.zone.now.hour

    Canteen.all.each do |canteen|
      next if hour < (canteen.fetch_hour || canteen.fetch_hour_default)
      next if hour > 14
      full_fetched_done = canteen.last_fetched_at and canteen.last_fetched_at.to_date == date

      begin
        canteen.fetch today: full_fetched_done
      rescue => e
        Rails.logger.warn "Error while fetching canteen data of #{canteen.id} (#{canteen.name}): #{e.message}"
      end
    end
  end

  task :daily_report => :environment do
    OpenMensa::DailyReportTask.new.do
  end
end
