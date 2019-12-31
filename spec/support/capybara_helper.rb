# frozen_string_literal: true

module Capybara
  class Session
    def has_link_to?(dest)
      has_xpath?("//a[contains(@href,\"#{dest}\")]")
    end
  end
end
