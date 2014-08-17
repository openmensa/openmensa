if Rails.env.production? or ENV['RAKWIK']
  if Rails.application.secrets.rakwik_auth_token
    require 'rakwik'

    Rails.application.config.middleware.use Rakwik::Tracker, \
      piwik_url: 'http://dev.altimos.de/piwik/piwik.php',
      site_id: '4',
      track_404: false,
      token_auth: Rails.application.secrets.rakwik_auth_token,
      path: '/api'
  end
end
