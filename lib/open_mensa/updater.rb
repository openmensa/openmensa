# frozen_string_literal: true

require "open-uri"
require_dependency "message"

class OpenMensa::Updater < OpenMensa::BaseUpdater
  include Nokogiri
  attr_reader :feed, :fetch

  def initialize(feed, reason, options = {})
    options = {version: nil, today: false}.update options
    @feed = feed
    @fetch = FeedFetch.create! feed: feed, executed_at: Time.zone.now,
                               reason: reason, state: "fetching"
    @version = options[:version]
    reset_stats
  end

  def messageable
    fetch
  end

  # 1. Fetch feed data
  def fetch!
    @data = OpenMensa::FeedLoader.new(feed, :url).load!
  rescue OpenMensa::FeedLoader::FeedLoadError => e
    e.cause.tap do |err|
      case err
        when URI::InvalidURIError
          Rails.logger.warn "Invalid URI (#{feed.url}) for #{feed.canteen.id} (#{feed.name})"
          @errors << FeedInvalidUrlError.create(messageable: feed)
          fetch.state = "broken"
        when OpenURI::HTTPError
          create_fetch_error! err.message, err.message.to_i
          fetch.state = "failed"
        else
          create_fetch_error! err.message
          fetch.state = "failed"
      end
    end
    fetch.save!
    false
  end

  # 2. Parse XML data
  def parse!
    @version  = nil
    @document = OpenMensa::FeedParser.new(data).parse!
  rescue OpenMensa::FeedParser::ParserError => e
    e.errors.take(2).each do |error|
      create_validation_error! :no_xml, error.message
    end
    fetch.state = "invalid"
    fetch.save!
    false
  end

  # 3. Validate XML document
  def validate!
    result = super
    fetch.version = version
    if result
      result
    else
      fetch.state = "invalid"
      fetch.save!
      false
    end
  end

  # 4. process data
  def add_meal(day, category, meal, pos = nil)
    day.meals.create(
      category: category,
      name: meal.children.find {|node| node.name == "name" }.content,
      pos: pos,
      prices: meal.children.each_with_object({}) do |node, prices|
        prices[node["role"]] = node.content if node.name == "price" && version.to_i == 2
      end,
      notes: meal.children.select {|n| n.name == "note" }.map(&:content)
    )
    fetch.added_meals += 1
    @changed = true
  end

  def update_meal(meal, _category, meal_data, pos = nil)
    meal.prices = meal_data.children.each_with_object(student: nil, employee: nil, pupil: nil, other: nil) do |node, prices|
      prices[node["role"]] = node.content if node.name == "price" && version.to_i == 2
    end
    meal.notes = meal_data.children.select {|n| n.name == "note" }.map(&:content)
    if meal.changed?
      fetch.updated_meals += 1
      @changed = true
      meal.pos = pos
      meal.save
    elsif pos != meal.pos
      meal.update pos: pos
    end
  end

  def add_day(day_data)
    return if Date.parse(day_data["date"]) < Date.today

    day = canteen.days.create(date: Date.parse(day_data["date"]))
    if day_data.children.any? {|node| node.name == "closed" }
      day.closed = true
      day.save!
    else
      pos = 1
      day_data.element_children.each do |category|
        category.element_children.each_with_object([]) do |meal, names|
          name = meal.children.find {|node| node.name == "name" }.content
          next if names.include? name

          add_meal(day, category["name"], meal, pos)
          pos += 1
          names << name
        end
      end
    end
    fetch.added_days += 1
    @changed = true
  end

  def update_day(day, day_data)
    return if Date.parse(day_data["date"]) < Date.today

    if day_data.children.any? {|node| node.name == "closed" }
      @changed = !day.closed?
      fetch.updated_days += 1 unless day.closed?
      day.meals.destroy_all
      day.update_attribute :closed, true
    else
      if day.closed?
        day.update_attribute :closed, false
        fetch.updated_days += 1
        @changed = true
      end
      names = day.meals.index_by do |value|
        [value.category, value.name.to_s]
      end
      pos = 1
      day_data.element_children.each do |category|
        category.element_children.each do |meal|
          name = meal.children.find {|node| node.name == "name" }.content
          meal_obj = names[[category["name"], name]]
          if meal_obj.is_a? Meal
            update_meal meal_obj, category["name"], meal, pos
            names[[category["name"], name]] = false
          elsif meal_obj.nil?
            add_meal day, category["name"], meal, pos
          end
          pos += 1
        end
      end
      names.keep_if {|_key, meal| meal }
      unless names.empty?
        fetch.removed_meals += names.size
        names.each_value(&:destroy)
        @changed = true
      end
    end
  end

  def update_canteen(canteen_data)
    days = canteen.days.index_by {|v| v.date.to_s; }
    day_updated = nil
    canteen_data.element_children.each do |day|
      next if day.name != "day"
      next if Date.parse(day["date"]) < Date.today

      canteen.transaction do
        date = day["date"]
        if days.key? date
          update_day days[date], day
        else
          add_day day
        end
        day_updated = true
      end
    end
    canteen.update_column :last_fetched_at, Time.zone.now if day_updated
    if !day_updated
      fetch.state = "empty"
    elsif changed?
      fetch.state = "changed"
      canteen.update state: "active"
    else
      fetch.state = "unchanged"
    end
    fetch.save!
    true
  end

  # all together
  def update(options = {})
    @version = options[:version] if options.key? :version

    return false unless fetch! && parse! && validate!

    fetch.init_counters
    update_canteen extract_canteen_node
  end

  def stats(json = true)
    if !errors.empty?
      {
        "errors" => json ? errors.map(&:to_json) : errors
      }
    else
      {
        "days" => {
          "added" => fetch.added_days,
          "updated" => fetch.updated_days
        },
        "meals" => {
          "added" => fetch.added_meals,
          "updated" => fetch.updated_meals,
          "removed" => fetch.removed_meals
        }
      }
    end
  end

  private

  def canteen
    feed.canteen
  end
end
