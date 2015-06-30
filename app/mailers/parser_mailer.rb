class ParserMailer < ActionMailer::Base
  default from: 'mail@openmensa.org'

  def daily_report(parser, data_since=nil)
    @parser = parser
    @user = parser.user
    @data_since = data_since
    reason_mail_content!
    return nil unless mail_sending_needed?
    mail to: @user.notify_email, subject: calculate_mail_subject
  end

  private

  def reason_mail_content!
    @notables = []
    @regulars = []
    @fetch_errors = []
    @feedbacks = []
    @parser.sources.each do |source|
      part = SourceMailerPart.new source, @data_since
      @feedbacks << part if part.new_feedback?
      if part.notable?
        @fetch_errors << part
        @notables << part
      else
        @regulars << part
        @notables << part if part.new_feedback?
      end
    end
  end

  def mail_sending_needed?
    !@notables.empty?
  end

  def calculate_mail_subject
    msg = [feedback_msg, feed_msg].reject(&:nil?).join(' & ')
    t 'subject', name: @parser.name, msg: msg
  end

  def t(name, *args)
    super 'mailer.daily_report.' + name, *args
  end

  def feed_msg
    return nil if @fetch_errors.empty?
    @notable_feeds = []
    @regular_feeds = []
    @tense = 'past'
    @fetch_errors.each do |source|
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

  def feedback_msg
    return nil if @feedbacks.empty?
    t 'new_feedbacks', count: @feedbacks.map(&:feedback_count).inject(&:+), sources: @feedbacks.map(&:name).join(', ')
  end

  def reason_feed_msg_subject!
    if @regular_feeds.empty?
      @count = 100
      @subject = if  @regulars.empty?
        t 'feed_subjects.all_feeds'
      else
        t 'feed_subjects.all_feeds_for', sources: @fetch_errors.map(&:name).join(', ')
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
                                                   sources: @fetch_errors.map(&:name).join(', ')
      end
    else
      @count = 100
      @subject = if @regulars.empty?
        t 'feed_subjects.some_feeds'
      else
        t 'feed_subjects.some_feeds_for', sources: @fetch_errors.map(&:name).join(', ')
      end
    end
  end

  class SourceMailerPart
    extend Forwardable
    def_delegators :@source, :name, :canteen
    attr_reader :feeds
    attr_reader :feedbacks

    def initialize(source, data_since)
      @source = source
      @feeds = source.feeds.map do |feed|
        FeedMailerPart.new feed, data_since
      end
      @feedbacks = source.canteen.feedbacks.where('created_at > ?', data_since).to_a
    end

    def notable?
      @feeds.any?(&:notable?)
    end

    def new_feedback?
      @feedbacks.any?
    end

    def feedback_count
      @feedbacks.size
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
      @histogram.select {|k,v| %w(invalid failed broken).include? k }.keys
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
