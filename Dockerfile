# syntax = docker/dockerfile:1.25@sha256:0adf442eae370b6087e08edc7c50b552d80ddf261576f4ebd6421006b2461f12

# Required images
FROM docker.io/ruby:4.0.5-slim-trixie@sha256:3d2d07ec3c267107a2a253327c108c1e5b74ea84cfa5ab125f127beb86dccd86 AS ruby
FROM docker.io/oven/bun:1@sha256:e10577f0db68676a7024391c6e5cb4b879ebd17188ab750cf10024a6d700e5c4 AS bun


# STAGE: Install the app dependencies and build frontend assets
FROM ruby AS build

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV RAILS_ENV=production
ENV RAILS_GROUPS=assets
ENV VITE_RUBY_SKIP_ASSETS_PRECOMPILE_INSTALL=true

RUN mkdir --parents /opt/openmensa
WORKDIR /opt/openmensa

RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  <<EOF
  apt-get --yes --quiet update
  apt-get --yes --quiet install \
    build-essential \
    libpq-dev \
    libyaml-dev
EOF

COPY Gemfile Gemfile.lock /opt/openmensa/
RUN --mount=type=cache,target=/root/.gem <<EOF
  bundle config set --local deployment 'true'
  bundle config set --local without 'development test'
  bundle install --jobs 4 --retry 3
EOF

COPY package.json bun.lock /opt/openmensa/
RUN \
  --mount=type=cache,target=/opt/openmensa/node_modules \
  --mount=type=cache,target=/root/.bun/install/cache \
  --mount=type=bind,from=bun,source=/usr/local/bin/bun,target=/usr/local/bin/bun \
  <<EOF
  bun install --frozen-lockfile
EOF

# Note: see also .dockerignore
COPY . /opt/openmensa/
RUN \
  --mount=type=cache,target=/opt/openmensa/log \
  --mount=type=cache,target=/opt/openmensa/node_modules \
  --mount=type=cache,target=/opt/openmensa/tmp \
  --mount=type=bind,from=bun,source=/usr/local/bin/bun,target=/usr/local/bin/bun \
  <<EOF
  bundle exec rake assets:precompile

  # Remove files and directories not needed at runtime; and not part of
  # a cache mount
  rm -rf app/frontend

  # Clean up bundler and gems cache, and development files from gems
  rm -rf vendor/bundle/ruby/*/cache
  rm -rf vendor/bundle/ruby/*/extensions/*/{*.log,*.out}
  rm -rf vendor/bundle/ruby/*/gems/*/{.git,.github,.gitlab-ci.yml,.travis.yml,appveyor.yml,.codecov.yml}
  rm -rf vendor/bundle/ruby/*/gems/*/{test,tests,spec,specs,features,examples,example}/
  rm -rf vendor/bundle/ruby/*/gems/*/{AGENT.md,CLAUDE.md,README.md,CHANGELOG.md,HISTORY.md,CONTRIBUTING.md,CONTRIBUTE.md,CONTRIBUTORS.md,CODE_OF_CONDUCT.md}
EOF


# STAGE: Final runtime image
FROM ruby AS runtime

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV RAILS_ENV=production
ENV BUNDLE_USER_HOME=/tmp

# Install native runtime dependencies
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  <<EOF
  apt-get --yes --quiet update
  apt-get --yes --quiet install --no-install-recommends libpq5
EOF

COPY --from=build /opt/openmensa /opt/openmensa
WORKDIR /opt/openmensa

RUN <<EOF
  bundle config set --local deployment 'true'
  bundle config set --local without 'development test'

  mkdir --parents /etc/openmensa /var/log/openmensa

  ln --symbolic /tmp /opt/openmensa/tmp
  ln --symbolic /var/log/openmensa /opt/openmensa/log
  ln --symbolic /opt/openmensa/config/{database.yml,omniauth.yml,settings.yml} /etc/openmensa

  useradd --create-home --home-dir /var/lib/openmensa --shell /bin/bash openmensa

  chown openmensa:openmensa /var/log/openmensa
EOF

USER openmensa

EXPOSE 80

VOLUME [ "/var/log/openmensa" ]

ENTRYPOINT [ "/opt/openmensa/bin/entrypoint" ]
CMD [ "server" ]
