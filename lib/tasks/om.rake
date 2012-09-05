namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Rails.logger.info "[#{Time.zone.now}] Fetch canteen data..."
    date = Time.zone.now.to_date

    Canteen.all.each do |canteen|
      next if canteen.last_fetched_at and canteen.last_fetched_at.to_date == date
      next if Time.zone.now.hour < canteen.fetch_hour

      begin
        canteen.fetch
      rescue => e
        Rails.logger.warn "Error while fetching canteen data of #{canteen.id} (#{canteen.name}): #{e.message}"
      end
    end
  end

  task :daily_report => :environment do
    OpenMensa::DailyReportTask.new.do
  end
end
