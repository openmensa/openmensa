namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Cafeteria.all.each do |cafeteria|
      begin
        cafeteria.fetch
      rescue Error => e
        puts e
        Rails.logger.warn "Error while fetching cafeteria data of #{cafeteria.id}: #{cafeteria.name}:\n" + e
      end
    end
  end
end
