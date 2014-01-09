require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

module Openmensa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('app', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    # Loaded OmniAuth services will be stored here
    config.omniauth_services = []

    # Load ruby platform specific database configuration
    def config.database_configuration
      files = []
      files += %W(/config/database.#{ENV['DB_ENV']}.#{RUBY_ENGINE}.yml /config/database.#{ENV['DB_ENV']}.yml) if ENV['DB_ENV']
      files += %W(/config/database.#{RUBY_ENGINE}.yml /config/database.yml)
      files.each do |file|
        file = Rails.root.to_s + file
        return YAML::load(ERB.new(IO.read(file)).result) if File.exists?(file)
      end
      raise 'No database configuration found.'
    end

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, expose: %w(Link X-OM-Api-Version X-Total-Pages), methods: :get, credentials: false
      end
    end
  end
end
