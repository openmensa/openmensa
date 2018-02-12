class OpenMensa::SourceUpdater < OpenMensa::BaseUpdater
  attr_reader :source
  attr_reader :feeds_added, :feeds_updated, :feeds_deleted

  def initialize(source)
    @source = source
    reset_stats
  end

  def messageable
    @source
  end

  def reset_stats
    super
    @feeds_added = 0
    @feeds_updated = 0
    @feeds_deleted = 0
  end

  # 1. Fetch feed data
  def fetch!
    @data = OpenMensa::FeedLoader.new(source, :meta_url).load!
  rescue OpenMensa::FeedLoader::FeedLoadError => error
    error.cause.tap do |err|
      case err
        when URI::InvalidURIError
          Rails.logger.warn "Invalid Meta-URI (#{source.meta_url}) for #{source.name})"
          @errors << FeedInvalidUrlError.create(messageable: source)
        when OpenURI::HTTPError
          create_fetch_error! err.message, err.message.to_i
        else
          create_fetch_error! err.message
      end
    end
    false
  end

  # 2. Parse XML data
  def parse!
    @document = OpenMensa::FeedParser.new(data).parse!
  rescue OpenMensa::FeedParser::ParserError => err
    err.errors.take(2).each do |error|
      create_validation_error! :no_xml, error.message
    end
    false
  end

  # 3. validate against OpenMensa Feed schema
  def validate!
    @min_version = 2
    super
  end

  # 4. all together
  def sync
    return false unless fetch! && parse! && validate!

    update_feeds extract_canteen_node
    update_metadata extract_canteen_node

    true
  end

  def stats
    {
      new_metadata: changed?,
      created: @feeds_added,
      updated: @feeds_updated,
      deleted: @feeds_deleted
    }
  end


  private

  def feeds_mapping
    @source.feeds.inject({}) do |memo, feed|
      memo[feed.name] = feed
      memo
    end
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
        data[:retry] = element['retry'].split(' ').map(&:to_i) if element.key? 'retry'
        data[:schedule] = [
          element['minute'] || '0',
          element['hour'],
          element['dayOfMonth'] || '*',
          element['month'] || '*',
          element['dayOfWeek'] || '*',
        ].join(' ')
      end
    end
    data
  end

  def update_feeds(canteen)
    feeds = feeds_mapping

    canteen.element_children.select do |node|
      next unless node.name == 'feed'
      name = node['name']
      if feeds.key? name
        update_feed feeds.fetch(name), node
        feeds.delete name
      else
        create_feed node
      end
    end
    feeds.each do |name, feed|
      delete_feed feed
    end
    true
  end

  def extract_metadata(canteen, canteen_node)
    canteen_node.element_children.select do |node|
      case node.name
        when 'name'
          canteen.name = node.content
        when 'address'
          canteen.address = node.content
        when 'city'
          canteen.city = node.content
        when 'phone'
          canteen.phone = node.content
        when 'location'
          canteen.latitude = node['latitude'].to_f
          canteen.longitude = node['longitude'].to_f
        when 'availability'
      end
    end
  end

  def update_metadata(canteen_node)
    canteen = @source.canteen

    extract_metadata(canteen, canteen_node)
    unless canteen.changed.empty?
      @changed = true
      new_data = {user: source.parser.user}
      new_data = canteen.changes.inject(new_data) do |memo, (attr, (old, new))|
        memo[attr] = new
        memo
      end
      canteen.data_proposals.find_or_create_by! new_data
    end
  end

  def create_feed(node)
    attrs = feed_data node
    attrs[:name] = node['name']
    attrs[:priority] = node['priority'].to_i
    feed = @source.feeds.create! attrs
    feed_changed!(feed, feed, :created)
    @feeds_added += 1
  end

  def update_feed(feed, node)
    feed.assign_attributes feed_data node
    unless (feed.changed - %w(created_at updated_at)).empty?
      feed.save!
      feed_changed!(feed, feed, :updated)
      @feeds_updated += 1
    end
  end

  def delete_feed(feed)
    feed_changed!(source, feed, :deleted)
    feed.destroy
    @feeds_deleted += 1
  end

  def feed_changed!(messageable, feed, kind)
    @errors << messageable.messages.create!(type: 'FeedChanged',
                                            kind: kind,
                                            name: feed.name)
  end
end
