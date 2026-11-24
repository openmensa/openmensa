# syntax = docker/dockerfile:1.29@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Required images
FROM docker.io/ruby:4.0.10-slim-trixie@sha256:67fb5dbef860bb2205a3c69799f7f1c4f5b01c943ae089de436bc266ea8c102e AS ruby
FROM docker.io/oven/bun:1@sha256:3aa040e5445efa09d75bb428a64ba50db13e2b3ac9b6b0c7f145615f62b2ee18 AS bun


# STAGE: Install the app dependencies and build frontend assets
FROM ruby AS build

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV RAILS_ENV=production
ENV RAILS_GROUPS=assets
ENV VITE_RUBY_SKIP_ASSETS_PRECOMPILE_INSTALL=true

# Outside of tmp/ to keep precompiled files in image
ENV BOOTSNAP_CACHE_DIR=/opt/openmensa/cache

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
  --mount=type=cache,target=/root/.bun/install/cache \
  --mount=type=bind,from=bun,source=/usr/local/bin/bun,target=/usr/local/bin/bun \
  <<EOF
  bun install --frozen-lockfile
EOF

# Note: see also .dockerignore
COPY . /opt/openmensa/
RUN \
  --mount=type=cache,target=/opt/openmensa/log \
  --mount=type=cache,target=/opt/openmensa/tmp \
  --mount=type=bind,from=bun,source=/usr/local/bin/bun,target=/usr/local/bin/bun \
  <<EOF
  bundle exec rake assets:precompile

  # Remove files and directories not needed at runtime; and not part of
  # a cache mount
  rm -rf app/frontend node_modules

  # Clean up bundler and gems cache, and development files from gems
  rm -rf vendor/bundle/ruby/*/cache
  rm -rf vendor/bundle/ruby/*/extensions/*/{*.log,*.out}
  rm -rf vendor/bundle/ruby/*/gems/*/{.git,.github,.gitlab-ci.yml,.travis.yml,appveyor.yml,.codecov.yml}
  rm -rf vendor/bundle/ruby/*/gems/*/{test,tests,spec,specs,features,examples,example}/
  rm -rf vendor/bundle/ruby/*/gems/*/{AGENT.md,CLAUDE.md,README.md,CHANGELOG.md,HISTORY.md,CONTRIBUTING.md,CONTRIBUTE.md,CONTRIBUTORS.md,CODE_OF_CONDUCT.md}

  # Precompile all Ruby and YAML files
  bundle exec bootsnap precompile --gemfile app/ lib/ config/
EOF


# STAGE: Final runtime image
FROM ruby AS runtime

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV RAILS_ENV=production
ENV BUNDLE_USER_HOME=/tmp

ENV BOOTSNAP_CACHE_DIR=/opt/openmensa/cache
ENV BOOTSNAP_READONLY=true

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

ARG REVISION
RUN <<-EOF
  [[ -z "${REVISION}" ]] || echo "${REVISION}" > /opt/openmensa/REVISION
EOF

USER openmensa

EXPOSE 80

VOLUME [ "/var/log/openmensa" ]

ENTRYPOINT [ "/opt/openmensa/bin/entrypoint" ]
CMD [ "server" ]
