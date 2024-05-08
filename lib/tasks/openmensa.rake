# frozen_string_literal: true

namespace :openmensa do
  desc "Fetch feed data"
  task update_feeds: :environment do
    OpenMensa::UpdateFeedsTask.new.do
  end

  desc "Fetch source meta data"
  task update_sources: :environment do
    OpenMensa::UpdateSourcesTask.new.do
  end

  desc "Fetch parser index lists"
  task update_parsers: :environment do
    OpenMensa::UpdateParsersTask.new.do
  end
end
