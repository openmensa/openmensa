require 'open-uri'
require 'rexml/document'

class Canteen < ActiveRecord::Base
  belongs_to :user
  has_many :meals

  attr_accessible :address, :name, :url, :user, :latitude, :longitude
  validates :address, :name, :user_id, presence: true

  geocoded_by :address
  after_validation :geocode, if: :geocode?

  def geocode?
    return false if Rails.env.test?
    !(address.blank? || (!latitude.blank? && !longitude.blank?)) || address_changed?
  end

  def fetch_hour
    read_attribute(:fetch_hour) || 8
  end

  def fetch
    return unless self.url
    uri = URI.parse self.url

    xml = REXML::Document.new open(uri).read

    case xml.root.attribute(:version).to_s
      when '1.0' then fetch_v1(xml)
      when '2.0' then fetch_v2(xml)
    end
  rescue URI::InvalidURIError
    Rails.logger.warn "Invalid URI (#{url}) in cafeteria #{id}"
  end

  def fetch_v1(xml)
    REXML::XPath.each(xml, '/cafeteria/day') do |day|
      begin
        date = Date.strptime day.attribute(:date).to_s, '%Y-%m-%d'

        REXML::XPath.each(day, 'category') do |cat|
          category = cat.attribute(:name).to_s

          transaction do
            self.meals.where(date: date, category: category).destroy_all

            REXML::XPath.each(cat, 'meal') do |node|
              meal = Meal.new canteen: self, date: date, category: category
              meal.name = REXML::XPath.first(node, 'name').text

              next if meal.name.to_s.empty?

              meal.description = ""
              REXML::XPath.each(node, 'note') do |note|
                meal.description += note.text.to_s + "\n" if note.text.to_s
              end
              meal.description.strip!

              meal.save!
            end

            # saved for each processed day :S
            self.meals.reset
            self.last_fetched_at = Time.zone.now
            self.save!
          end
        end
      rescue
        $stderr.puts $!.inspect
      end
    end
  end

  def fetch_v2(xml)
    REXML::XPath.each(xml, '/openmensa/canteen/day') do |day|
      begin
        date = Date.strptime day.attribute(:date).to_s, '%Y-%m-%d'

        #REXML::XPath.first(day, 'closed')

        REXML::XPath.each(day, 'category') do |cat|
          category = cat.attribute(:name).to_s
          transaction do
            self.meals.where(date: date, category: category).destroy_all

            REXML::XPath.each(cat, 'meal') do |node|
              meal = Meal.new canteen: self, date: date, category: category
              meal.name = REXML::XPath.first(node, 'name').text

              # TODO: fetch a meal's notes and prices
              REXML::XPath.each(node, 'note') do |note| end
              REXML::XPath.each(node, 'price') do |price| end

              meal.save!
            end

            self.meals.reset
            self.last_fetched_at = Time.zone.now
            self.save!
          end
        end
      rescue
        $stderr.puts $!.inspect
      end
    end
  end
end
