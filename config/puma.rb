# Puma configuration file
#

# Get rails environment
RAILS_ENV = ENV['RAILS_ENV'] || 'development'

# Use 2 to 4 threads
threads 2,4

# Preload app to share most code
preload_app!

# Listen on a unix socket
bind 'unix:' + File.realpath('tmp/sockets') + '/web.sock'

# Setup pid and state file
pidfile    'tmp/puma/pid'
state_path 'tmp/puma/state'
activate_control_app

# Log to /application/current/log/ files, we are already in RAILS_ROOT
stdout_redirect 'log/puma.log', 'log/puma.err.log', true if RAILS_ENV == 'production'

# Set server environment
environment RAILS_ENV
