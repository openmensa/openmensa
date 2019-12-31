# frozen_string_literal: true

# fix strange port numbers due to proxy
if Rails.env.production?
  OmniAuth.config.full_host = 'https://openmensa.org'
end

OMNI_FILE = Rails.application.secrets.omni_file || Rails.root.join('config', 'omniauth.yml')
OMNI_CONFIG = YAML.load_file(OMNI_FILE)[Rails.env]

if OMNI_CONFIG
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, OMNI_CONFIG['github']['key'], OMNI_CONFIG['github']['secret'], skip_info: true if OMNI_CONFIG['github']
    provider :twitter, OMNI_CONFIG['twitter']['key'], OMNI_CONFIG['twitter']['secret'] if OMNI_CONFIG['twitter']
    provider :facebook, OMNI_CONFIG['facebook']['key'], OMNI_CONFIG['facebook']['secret'] if OMNI_CONFIG['facebook']
    provider :google_oauth2, OMNI_CONFIG['google_oauth2']['key'], OMNI_CONFIG['google_oauth2']['secret'] if OMNI_CONFIG['google_oauth2']
  end
end

(OMNI_CONFIG || []).each do |key, _data|
  Rails.configuration.omniauth_services ||= []
  Rails.configuration.omniauth_services << key
end
