require 'open-uri'
require 'rexml/document'

class Cafeteria < ActiveRecord::Base
  belongs_to :user
  has_many :meals

  attr_accessible :address, :name, :url, :user
  validates :address, :name, :user_id, presence: true

  def fetch_hour
    read_attribute(:fetch_hour) || 8
  end

  def fetch
    return unless self.url
    uri = URI.parse self.url

    transaction do
      xml = REXML::Document.new open(uri).read

      REXML::XPath.each(xml, '/cafeteria/day') do |day|
        date = Date.strptime day.attribute(:date).to_s, '%Y-%m-%d'

        REXML::XPath.each(day, 'category') do |cat|
          category = cat.attribute(:name).to_s
          self.meals.where(date: date, category: category).destroy_all

          REXML::XPath.each(cat, 'meal') do |node|
            meal = Meal.new cafeteria: self, date: date, category: category
            meal.name = REXML::XPath.first(node, 'name').text

            meal.description = ""
            REXML::XPath.each(node, 'note') do |note|
              meal.description += note.text + "\n"
            end
            meal.description.strip!

            meal.save!
          end
        end
      end

      self.meals.reset
      self.last_fetched_at = Time.zone.now
      self.save!
    end
  rescue URI::InvalidURIError
    Rails.logger.warn "Invalid URI (#{url}) in cafeteria #{id}"
  end
end
