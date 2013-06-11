if Rails.env.production?
  config.middleware.use Rakwik::Tracker, piwik_url: 'http://dev.altimos.de/piwik.php',
                        site_id: '4', token_auth: ENV['RAKWIK_AUTH_TOKEN']
end
