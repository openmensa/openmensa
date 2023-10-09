# frozen_string_literal: true

class FeedUrlUpdatedInfo < Message
  def default_priority
    :info
  end

  def old_url
    payload[:old_url]
  end

  def old_url=(url)
    payload[:old_url] = url
  end

  def new_url
    payload[:new_url]
  end

  def new_url=(url)
    payload[:new_url] = url
  end
end
