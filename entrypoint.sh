#!/bin/sh

# Abort script if any step fails. This ensures errors are detected and
# we do not start an only partially working application.
set -e

case "$1" in
sh | bash)
  set -- "$@"
  ;;
server)
  # Remove 'server' from argument list
  shift

  # Copy assets into mounted volume as they need to be served by the nginx
  # container or from the host nginx.
  echo "[INFO] Copy assets to volume..."
  (set -x; cp -ar /opt/openmensa/public/. /mnt/www)

  # Create database and run all migrations. If no changes are needed,
  # nothing will happen.
  echo "[INFO] Run database migrations..."
  (set -x; bundle exec rake db:create db:migrate)

  echo "[INFO] Start server..."
  set -- bundle exec rails server "$@"
  ;;
esac

(set -x; exec "$@")
