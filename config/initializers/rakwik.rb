if Rails.env.production? or ENV['RAKWIK']
  if ENV['RAKWIK_AUTH_TOKEN']
    Rails.application.config.middleware.use Rakwik::Tracker, piwik_url: 'http://dev.altimos.de/piwik/piwik.php',
                                            site_id: '4', token_auth: ENV['RAKWIK_AUTH_TOKEN'], track_404: false,
                                            path: '/api'
  else
    Rails.logger.warn 'No RAKWIK_ATH_TOKEN given.'
  end
end
