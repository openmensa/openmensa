class ParserMailer < ActionMailer::Base
  default from: 'mail@openmensa.org'

  def daily_report(parser, data_since=nil)
    @parser = parser
    @user = parser.user
    @data_since = data_since
    reason_mail_content!
    return nil unless mail_sending_needed?
    mail to: @user.email, subject: calculate_mail_subject
  end

  private

  def reason_mail_content!
    @notables = []
    @regulars = []
    @parser.sources.each do |source|
      part = SourceMailerPart.new source, @data_since
      if part.notable?
        @notables << part
      else
        @regulars << part
      end
    end
  end

  def mail_sending_needed?
    !@notables.empty?
  end

  def calculate_mail_subject
    msg = feed_msg
    t 'subject', name: @parser.name, msg: msg
  end

  def t(name, *args)
    super 'mailer.daily_report.' + name, *args
  end

  def feed_msg
    @notable_feeds = []
    @regular_feeds = []
    @tense = 'past'
    @notables.each do |source|
      source.feeds.each do |feed|
        if feed.notable?
          @notable_feeds << feed
        else
          @regular_feeds << feed
        end
        @tense = 'presence' if feed.presence?
      end
    end
    reason_feed_msg_subject!
    descs = @notable_feeds.map(&:seen_states).flatten.uniq
    t "feed_singleton_msgs.#{@tense}.#{descs.sort.join("_")}", subject: @subject, count: @count
  end

  def reason_feed_msg_subject!
    if @regular_feeds.empty?
      @count = 100
      @subject = if  @regulars.empty?
        t 'feed_subjects.all_feeds'
      else
        t 'feed_subjects.all_feeds_for', sources: @notables.map(&:name).join(', ')
      end
    elsif @notable_feeds.size == 1
      @count = 1
      @subject = t 'feed_subjects.one_feed', name: @notable_feeds.first.name,
                                             source: @notable_feeds.first.source_name
    elsif @notable_feeds.map(&:name).uniq.size == 1
      @count = 100
      @subject = if @regulars.empty?
        t 'feed_subjects.all_feeds_with_name', name: @notable_feeds.first.name
      else
        t 'feed_subjects.all_feeds_with_name_for', name: @notable_feeds.first.name,
                                                   sources: @notables.map(&:name).join(', ')
      end
    else
      @count = 100
      @subject = if @regulars.empty?
        t 'feed_subjects.some_feeds'
      else
        t 'feed_subjects.some_feeds_for', sources: @notables.map(&:name).join(', ')
      end
    end
  end

  class SourceMailerPart
    extend Forwardable
    def_delegators :@source, :name, :canteen
    attr_reader :feeds

    def initialize(source, data_since)
      @source = source
      @feeds = source.feeds.map do |feed|
        FeedMailerPart.new feed, data_since
      end
    end

    def notable?
      @feeds.any?(&:notable?)
    end
  end

  class FeedMailerPart
    extend Forwardable
    def_delegators :@feed, :name, :url

    def initialize(feed, data_since)
      @feed = feed
      @fetches = if data_since.nil?
        feed.fetches
      else
        feed.fetches.where('executed_at > ?', data_since)
      end.order(:executed_at).to_a
      build_state_histogram!
    end

    def build_state_histogram!
      @histogram = @fetches.inject({}) do |histogram, fetch|
        histogram[fetch.state] ||= 0
        histogram[fetch.state] += 1
        histogram
      end
      @histogram.default = 0
    end

    def notable?
      (@histogram['failed'] + @histogram['broken'] + @histogram['invalid']) > 0
    end
    def regular?
      !notable?
    end

    def seen_states
      @histogram.keys
    end

    def messages
      messages = @fetches.map(&:messages).flatten
      messages.sort_by { |m| m.created_at }.group_by {|m| [m.type, m.data] }.each do |_, msgs|
        yield [msgs.first, msgs.size, msgs.first.created_at, msgs.last.created_at]
      end
    end

    def source_name
      @feed.source.name
    end

    def presence?
      @fetches.last && %w(failed broken invalid).include?(@fetches.last.state)
    end
  end
end
