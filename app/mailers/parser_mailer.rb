# frozen_string_literal: true

class ParserMailer < ApplicationMailer
  def daily_report(parser, data_since = nil)
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
    @data_proposals = []
    @parser_messages = @parser.messages.where("created_at > ?", @data_since).to_a
    @sources = []
    @parser.sources.each do |source|
      part = SourceMailerPart.new source, @data_since
      @sources << part
      @feedbacks << part if part.new_feedback?
      @data_proposals << part if part.new_proposal?
      if part.notable?
        @fetch_errors << part
        @notables << part
      else
        @regulars << part
        @notables << part if part.new_feedback? || part.new_proposal? || part.messages? || part.feed_messages?
      end
    end
  end

  def mail_sending_needed?
    @notables.any? || @parser_messages.any?
  end

  def calculate_mail_subject
    msg = [messages_msg, feedback_msg, data_proposal_msg, feed_msg].compact.join(" & ")
    t "subject", name: @parser.name, msg: msg
  end

  def t(name, *args, **kwargs)
    super("mailer.daily_report.#{name}", *args, **kwargs)
  end

  def messages_msg
    subjects = []
    subjects << t("parser_subject") unless @parser_messages.empty?
    @sources.each do |source|
      subjects << t("source_subject", name: source.name) if source.messages?
      source.feeds.each do |feed|
        subjects << t("feed_subject", source: source.name, feed: feed.name) if feed.feed_messages?
      end
    end
    return nil if subjects.empty?

    t "messages_subject", subjects: subjects.join(", ")
  end

  def feed_msg
    return nil if @fetch_errors.empty?

    @notable_feeds = []
    @regular_feeds = []
    @tense = "past"
    @fetch_errors.each do |source|
      source.feeds.each do |feed|
        if feed.notable?
          @notable_feeds << feed
        else
          @regular_feeds << feed
        end
        @tense = "presence" if feed.presence?
      end
    end
    reason_feed_msg_subject!
    descs = @notable_feeds.map(&:seen_states).flatten.uniq
    t "feed_singleton_msgs.#{@tense}.#{descs.sort.join('_')}", subject: @subject, count: @count
  end

  def feedback_msg
    return nil if @feedbacks.empty?

    t "new_feedbacks", count: @feedbacks.sum(&:feedback_count), sources: @feedbacks.map(&:name).join(", ")
  end

  def data_proposal_msg
    return nil if @data_proposals.empty?

    t "new_data_proposals", count: @data_proposals.sum(&:proposal_count),
      sources: @data_proposals.map(&:name).join(", ")
  end

  def reason_feed_msg_subject!
    if @regular_feeds.empty?
      @count = 100
      @subject = if @regulars.empty?
                   t "feed_subjects.all_feeds"
                 else
                   t "feed_subjects.all_feeds_for", sources: @fetch_errors.map(&:name).join(", ")
                 end
    elsif @notable_feeds.size == 1
      @count = 1
      @subject = t "feed_subjects.one_feed", name: @notable_feeds.first.name,
        source: @notable_feeds.first.source_name
    elsif @notable_feeds.map(&:name).uniq.size == 1
      @count = 100
      @subject = if @regulars.empty?
                   t "feed_subjects.all_feeds_with_name", name: @notable_feeds.first.name
                 else
                   t "feed_subjects.all_feeds_with_name_for", name: @notable_feeds.first.name,
                     sources: @fetch_errors.map(&:name).join(", ")
                 end
    else
      @count = 100
      @subject = if @regulars.empty?
                   t "feed_subjects.some_feeds"
                 else
                   t "feed_subjects.some_feeds_for", sources: @fetch_errors.map(&:name).join(", ")
                 end
    end
  end

  class SourceMailerPart
    extend Forwardable
    def_delegators :@source, :name, :canteen
    attr_reader :feeds, :feedbacks, :data_proposals, :messages

    def initialize(source, data_since)
      @source = source
      @feeds = source.feeds.map do |feed|
        FeedMailerPart.new feed, data_since
      end
      @messages = source.messages.where("created_at > ?", data_since).to_a
      @feedbacks = source.canteen.feedbacks.where("created_at > ?", data_since).to_a
      @data_proposals = source.canteen.data_proposals.where("created_at > ?", data_since).to_a
    end

    def notable?
      @feeds.any?(&:notable?)
    end

    def new_feedback?
      @feedbacks.any?
    end

    def new_proposal?
      @data_proposals.any?
    end

    def feedback_count
      @feedbacks.size
    end

    def proposal_count
      @data_proposals.size
    end

    def messages?
      @messages.any?
    end

    def feed_messages?
      @feeds.any?(&:feed_messages?)
    end
  end

  class FeedMailerPart
    extend Forwardable
    def_delegators :@feed, :name, :url
    attr_reader :feed_messages

    def initialize(feed, data_since)
      @feed = feed
      @fetches = if data_since.nil?
                   feed.fetches.order(:executed_at)
                 else
                   feed.fetches.where("executed_at > ?", data_since).order(:executed_at)
                 end
      @feed_messages = feed.messages.where("created_at > ?", data_since).to_a

      build_state_histogram!
    end

    def build_state_histogram!
      @histogram = @fetches.each_with_object(Hash.new(0)) do |fetch, histogram|
        histogram[fetch.state] += 1
      end
    end

    def notable?
      (@histogram["failed"] + @histogram["broken"] + @histogram["invalid"]).positive?
    end

    def regular?
      !with_messages?
    end

    def with_messages?
      notable? || feed_messages?
    end

    def seen_states
      @histogram.select {|k, _v| %w[invalid failed broken].include? k }.keys
    end

    def messages
      messages = @fetches.map(&:messages).flatten
      messages.sort_by(&:created_at).group_by {|m| [m.type, m.data] }.each do |_, msgs|
        yield [msgs.first, msgs.size, msgs.first.created_at, msgs.last.created_at]
      end
    end

    def feed_messages?
      @feed_messages.any?
    end

    def source_name
      @feed.source.name
    end

    def presence?
      @fetches.last && %w[failed broken invalid].include?(@fetches.last.state)
    end
  end
end
