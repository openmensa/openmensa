class OpenMensa::FeedSynchroniser
  attr_reader :feeds_added, :feeds_updated, :feeds_deleted
  def initialize(source)
    @source = source
    reset_stats
  end

  def reset_stats
    @changed = false
    @feeds_added = 0
    @feeds_updated = 0
    @feeds_deleted = 0
  end

  def changed?
    @changed
  end

  def sync
    data = open @source.meta_url
    document = OpenMensa::FeedParser.new(data).parse!
    OpenMensa::FeedValidator.new(document)

    feeds = @source.feeds.inject({}) do |memo, feed|
      memo[feed.name] = feed
      memo
    end

    node = document.root.children.first
    node = node.next while node.name != 'canteen'
    node.element_children.each do |feed|
      next if feed.name != 'feed'
      name = feed['name']
      if feeds.key? name
        old_feed = feed[name]
        old_feed.update_attributes feed_data feed
        if old_feed.changed?
          old_feed.save
          @feeds_updated += 1
        end
        feeds.delete name
      else
        attrs = feed_data feed
        attrs[:name] = name
        attrs[:priority] = feed['priority'].to_i
        @source.feeds.create attrs
        @feeds_added += 1
      end
    end
    feeds.each do |name, feed|
      feed.delete
      @feeds_deleted += 1
    end
  rescue OpenMensa::FeedParser::ParserError => err
    false
  rescue OpenMensa::FeedValidator::InvalidFeedVersionError
    false
  rescue OpenMensa::FeedValidator::FeedValidationError => err
    false
  end
  def feed_data(element)
    data = {}
    element.element_children.each do |element|
      case element.name
      when 'url'
        data[:url] = element.content
      when 'source'
        data[:source_url] = element.content
      when 'schedule'
        data[:retry] = element['retry']
        data[:schedule] = [element['minute'], element['hour'], element['month'],
                        element['dayOfWeek'], element['dayOfMonth']].join(' ')
      end
    end
    data
  end
end
