# frozen_string_literal: true

# fix strange port numbers due to proxy
OmniAuth.config.full_host = "https://openmensa.org" if Rails.env.production?

Rails.configuration.omniauth_services = []

omniauth = Rails.application.config_for(:omniauth)
if omniauth
  Rails.application.config.middleware.use OmniAuth::Builder do
    omniauth.each_pair do |key, config|
      case key
        when :github
          provider :github, config.fetch(:key), config.fetch(:secret), skip_info: true
        when :twitter
          provider :twitter, config.fetch(:key), config.fetch(:secret)
        when :facebook
          provider :facebook, config.fetch(:key), config.fetch(:secret)
        when :microsoft
          provider :microsoft, config.fetch(:key), config.fetch(:secret), prompt: :select_account
        when :google
          provider :google_oauth2, config.fetch(:key), config.fetch(:secret), name: "google", prompt: :select_account
        else
          warn "Unknown omniauth strategy: #{key.inspect}"
          next
      end

      Rails.configuration.omniauth_services << key if config.fetch(:show, true)
    end
  end
end
