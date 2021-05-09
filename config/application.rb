# frozen_string_literal: true

require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
#
# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w[development test]))

module Openmensa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Berlin"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("app/locales/**/*.{rb,yml}").to_s]
    config.i18n.default_locale = :de

    # Loaded OmniAuth services will be stored here
    config.omniauth_services = []

    # Configure parameter filtering for logging
    config.filter_parameters += [:password]

    # Session store
    config.session_store :cookie_store, key: "_openmensa_session", secure: Rails.env.production?
    config.action_dispatch.cookies_serializer = :hybrid
    config.action_dispatch.cookies_same_site_protection = :lax

    # Version of your assets, change this if you want to expire all your assets.
    config.assets.version = "1.0"

    # Add additional assets to the asset load path.
    # Rails.application.config.assets.paths << Emoji.images_path
    # Add Yarn node_modules folder to the asset load path.
    config.assets.paths << Rails.root.join("node_modules")

    # Precompile additional assets.
    # application.js, application.css, and all non-JS/CSS in the app/assets
    # folder are already added.
    # config.assets.precompile += %w( admin.js admin.css )

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
  end
end
