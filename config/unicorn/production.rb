# unicorn configuration
# based on GitHub's configuration
# unicorn -c ./config/unicorn.rb -E production -D

rails_env = ENV['RAILS_ENV'] || 'production'

# 2 workers and 1 master
worker_processes 2

# Load application into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a unix socket
listen File.absolute_path('./tmp/sockets/unicorn.sock'), :backlog => 2048

# Setup pid file
pid './tmp/pids/unicorn.pid'

# Log to /application/current/log/ files, we are allready in RAILS_ROOT
stderr_path 'log/unicorn.err.log'
stdout_path 'log/unicorn.log'


##
# Ruby Enterprise Edition (REE) with COW
# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end


before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.

  old_pid = Rails.root + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end


after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket
end
