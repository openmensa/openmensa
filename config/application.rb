# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

require "good_job/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
#
Bundler.require(*Rails.groups)

module Openmensa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Berlin"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("app/locales/**/*.{rb,yml}").to_s]
    config.i18n.default_locale = :de

    # Loaded OmniAuth services will be stored here
    config.omniauth_services = []

    # Configure parameters to be partially matched (e.g. passw matches
    # password) and filtered from the log file. Use this to limit
    # dissemination of sensitive information. See the
    # ActiveSupport::ParameterFilter documentation for supported
    # notations and behaviors.
    config.filter_parameters += %i[passw secret token _key crypt salt certificate otp ssn]

    # Session store
    config.session_store :cookie_store, key: "_openmensa_session", secure: Rails.env.production?
    config.action_dispatch.cookies_serializer = :hybrid
    config.action_dispatch.cookies_same_site_protection = :lax

    # Assets
    config.assets_manifest.path = Rails.public_path.join("assets/packed/.manifest.json")
    config.assets_manifest.passthrough = true

    # Mailer settings
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = {host: "openmensa.org", protocol: "https"}

    # Allowed classes to be deserialized in YAML-encoded database
    # columns
    config.active_record.yaml_column_permitted_classes = [Symbol]

    config.middleware.use Rack::Cors do
      allow do
        origins "*"
        resource "/api/*", headers: :any, expose: %w[Link X-OM-Api-Version X-Total-Pages], methods: :get, credentials: false
      end
    end

    config.content_security_policy do |policy|
      policy.default_src :self
      policy.font_src    :self, :https, :data
      policy.img_src     :self, :https, :data, "https://openmensa.org"
      policy.object_src  :none
      policy.script_src  :self
      policy.style_src   :self
    end

    config.permissions_policy do |f|
      f.camera      :none
      f.gyroscope   :none
      f.microphone  :none
      f.usb         :none
      f.fullscreen  :self
      f.payment     :none
    end
  end
end
