# syntax = docker/dockerfile:1.24@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

# Ruby base image:
FROM docker.io/ruby:4.0.5-slim-trixie@sha256:d704a39f7be2941b5447a5ac84085707736eb9c1b4d9c68bcf383fda48f91983 AS ruby

# Bun base image:
FROM docker.io/oven/bun:1@sha256:e10577f0db68676a7024391c6e5cb4b879ebd17188ab750cf10024a6d700e5c4 AS bun


# STAGE: Build frontend assets
FROM bun AS assets

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV NODE_ENV=production

RUN mkdir --parents /opt/openmensa
WORKDIR /opt/openmensa

COPY package.json bun.lock /opt/openmensa/
RUN <<EOF
  bun install --frozen-lockfile
EOF

COPY vite.config.mts /opt/openmensa/
COPY config/vite.json /opt/openmensa/config/
COPY app/frontend/ /opt/openmensa/app/frontend/
RUN <<EOF
  bun run build --mode production
EOF


# STAGE: Build the Ruby application and extra assets
FROM ruby AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV RAILS_ENV=production
ENV RAILS_GROUPS=assets
ENV SKIP_JS_BUILD=1

RUN mkdir --parents /opt/openmensa
WORKDIR /opt/openmensa

# Install build dependencies for gems with native extensions
RUN <<EOF
  apt-get --yes --quiet update
  apt-get --yes --quiet install \
    build-essential \
    libpq-dev \
    libyaml-dev
EOF

COPY Gemfile Gemfile.lock /opt/openmensa/
RUN <<EOF
  gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
  bundle config set --local deployment 'true'
  bundle config set --local without 'development test'
  bundle install --jobs 4 --retry 3
EOF

# Note: see also .dockerignore
COPY . /opt/openmensa/
RUN <<EOF
  bundle exec rake assets:precompile
  rm -rf app/frontend log tmp
EOF


# STAGE: Final runtime image
FROM ruby AS runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV RAILS_ENV=production

COPY --from=assets /opt/openmensa/public /opt/openmensa/public
COPY --from=build /opt/openmensa /opt/openmensa
WORKDIR /opt/openmensa

# Install native runtime dependencies
RUN <<EOF
  apt-get --yes --quiet update
  apt-get --yes --quiet install --no-install-recommends libpq5
  rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
  gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
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

ENTRYPOINT [ "/opt/openmensa/bin/entrypoint" ]
CMD [ "server" ]
