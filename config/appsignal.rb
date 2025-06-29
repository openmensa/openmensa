# frozen_string_literal: true

# AppSignal Ruby gem configuration
#
# Visit our documentation for a list of all available configuration
# options: https://docs.appsignal.com/ruby/configuration/options.html.
Appsignal.configure do |config|
  push_api_key = ENV.fetch("APPSIGNAL_PUSH_API_KEY", Settings.appsignal&.push_api_key)

  config.activate_if_environment(:development, :production) if push_api_key.present?
  config.name = "OpenMensa"
  config.push_api_key = push_api_key

  revision_file = Rails.root.join("REVISION")
  config.revision = revision_file.read.strip[0..7] if revision_file.exist?
end
