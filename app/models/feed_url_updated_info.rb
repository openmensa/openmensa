# frozen_string_literal: true

class FeedUrlUpdatedInfo < Message
  def default_priority
    :info
  end

  def old_url
    data[:old_url]
  end

  def old_url=(url)
    data[:old_url] = url
  end

  def new_url
    data[:new_url]
  end

  def new_url=(url)
    data[:new_url] = url
  end
end
