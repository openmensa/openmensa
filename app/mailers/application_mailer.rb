# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "mail@openmensa.org"

  before_action do
    # https://www.arp242.net/autoreply.html

    # RFC 3834
    headers['Auto-Submitted'] = 'auto-generated'

    # Microsoft
    headers['X-Auto-Response-Suppress'] = 'All'
  end
end
