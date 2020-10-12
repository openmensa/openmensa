# frozen_string_literal: true

ENV_FILE = ENV["ENV_FILE"] || Rails.root.join("config", "env.yml")
begin
  ENV_CONFIG = YAML.load_file ENV_FILE

  if (env = ENV_CONFIG[Rails.env])
    env.each do |key, str|
      ENV[key] ||= str.to_s
    end
  end
rescue StandardError
  Rails.logger.warn "No ENV loaded from file #{ENV_FILE}."
end
