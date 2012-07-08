namespace :om do
  desc "Fetch data for all cafeterias"
  task :fetch => :environment do
    Cafeteria.all.each do |cafeteria|
      cafeteria.fetch
    end
  end
end
