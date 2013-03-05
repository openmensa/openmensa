require 'transactional'

module OpenMensa
  TITLE = 'OpenMensa'

  autoload :FeedLoader, 'open_mensa/feed_loader'
  autoload :FeedParser, 'open_mensa/feed_parser'
  autoload :FeedValidator, 'open_mensa/feed_validator'
end
