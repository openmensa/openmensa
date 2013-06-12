namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Rails.logger.info "[#{Time.zone.now}] Fetch canteen data..."

    Canteen.all.each do |canteen|
      begin
        canteen.fetch_if_needed
      rescue => e
        Rails.logger.warn "Error while fetching canteen data of #{canteen.id} (#{canteen.name}): #{e.message}"
      end
    end
  end

  task :daily_report => :environment do
    OpenMensa::DailyReportTask.new.do
  end
end
