namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Rails.logger.info "[#{Time.zone.now}] Fetch canteen data..."

    Canteen.active.pluck(:id).each do |canteen_id|
      canteen = Canteen.find canteen_id

      begin
        canteen.fetch_if_needed
      rescue => e
        Rails.logger.warn "Error while fetching canteen data of #{canteen.id} (#{canteen.name}): #{e.message}"
      end

      GC.start
    end
  end

  task :daily_report => :environment do
    OpenMensa::DailyReportTask.new.do
  end
end
