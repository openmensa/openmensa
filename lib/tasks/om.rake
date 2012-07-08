namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    date = Time.zone.now.to_date

    Cafeteria.all.each do |cafeteria|
      next if cafeteria.last_fetched_at.to_date == date
      next if Time.zone.now.hour < cafeteria.fetch_hour

      begin
        cafeteria.fetch
      rescue Error => e
        puts e
        Rails.logger.warn "Error while fetching cafeteria data of #{cafeteria.id}: #{cafeteria.name}:\n" + e
      end
    end
  end
end
