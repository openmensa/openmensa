# frozen_string_literal: true

# fix strange port numbers due to proxy
OmniAuth.config.full_host = "https://openmensa.org" if Rails.env.production?

OMNI_FILE = Rails.application.secrets.omni_file || Rails.root.join("config/omniauth.yml")
OMNI_CONFIG = YAML.safe_load_file(OMNI_FILE, aliases: true)[Rails.env]

Rails.configuration.omniauth_services = []

if OMNI_CONFIG
  Rails.application.config.middleware.use OmniAuth::Builder do
    OMNI_CONFIG.each_pair do |key, config|
      case key
        when "github"
          provider :github, config.fetch("key"), config.fetch("secret"), skip_info: true
        when "twitter"
          provider :twitter, config.fetch("key"), config.fetch("secret")
        when "facebook"
          provider :facebook, config.fetch("key"), config.fetch("secret")
        when "microsoft"
          provider :microsoft, config.fetch("key"), config.fetch("secret")
        when "google"
          provider :google_oauth2, config.fetch("key"), config.fetch("secret"), name: "google"
        else
          warn "Unknown omniauth strategy: #{key}"
          next
      end

      Rails.configuration.omniauth_services << key if config.fetch("show", true)
    end
  end
end
