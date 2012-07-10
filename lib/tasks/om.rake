namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Rails.logger.info "[#{Time.zone.now}] Fetch cafeteria data..."
    date = Time.zone.now.to_date

    Cafeteria.all.each do |cafeteria|
      next if cafeteria.last_fetched_at and cafeteria.last_fetched_at.to_date == date
      next if Time.zone.now.hour < cafeteria.fetch_hour

      begin
        cafeteria.fetch
      rescue
        Rails.logger.warn "Error while fetching cafeteria data of #{cafeteria.id}: #{cafeteria.name}"
      end
    end
  end
end
