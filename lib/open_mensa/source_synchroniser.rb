class OpenMensa::SourceSynchroniser
  attr_reader :sources_added, :sources_updated, :sources_deleted
  def initialize(parser)
    @parser = parser
    reset_stats
  end

  def reset_stats
    @changed = false
    @sources_added = 0
    @sources_updated = 0
    @sources_deleted = 0
  end

  def changed?
    @changed
  end

  def sync
    data = JSON.load open(@parser.info_url).read()
    sources = @parser.sources.inject({}) do |memo, source|
      memo[source.name] = source
    end
    data.each do |name, url|
      if sources.key? name
        if sources.meta_url != url
          sources.meta_url = url
          sources.save
          @sources_updated += 1
        end
        sources.delete name
      else
        @parser.sources.create meta_url: url, name: name
        @sources_added += 1
      end
    end
    sources.each do |name, source|
      source.state = 'delete'
      @sources_deleted += 1
    end
  end
end
