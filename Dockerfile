# syntax = docker/dockerfile:1.7

FROM docker.io/node:22-slim AS assets

ENV NODE_ENV=production
ENV YARN_CACHE_FOLDER=/cache/yarn

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir --parents /opt/openmensa
WORKDIR /opt/openmensa

COPY .yarnrc.yml package.json yarn.lock rspack.config.mjs app/javascripts /opt/openmensa/
RUN --mount=type=cache,target=/cache/yarn <<EOF
  corepack enable
  yarn install --immutable
EOF

COPY rspack.config.mjs /opt/openmensa/
COPY app/javascripts/ /opt/openmensa/app/javascripts/
RUN <<EOF
  yarn build --mode production
EOF


FROM docker.io/ruby:3.3.2-slim-bullseye AS build

ENV RAILS_ENV=production
ENV RAILS_GROUPS=assets
ENV SKIP_JS_BUILD=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir --parents /opt/openmensa
WORKDIR /opt/openmensa

# Install build dependencies for gems with native extensions
RUN <<EOF
  apt-get --yes --quiet update
  apt-get --yes --quiet install \
    build-essential \
    libpq-dev
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
  rm -rf /opt/openmensa/log /opt/openmensa/tmp
EOF


FROM docker.io/ruby:3.3.2-slim-bullseye

ENV RAILS_ENV=production

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=assets /opt/openmensa /opt/openmensa
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
  mkdir --parents /etc/openmensa /var/log/openmensa /mnt/www
  ln --symbolic /tmp /opt/openmensa/tmp
  ln --symbolic /var/log/openmensa /opt/openmensa/log
  ln --symbolic /opt/openmensa/config/{database.yml,omniauth.yml,secrets.yml} /etc/openmensa
  useradd --create-home --home-dir /var/lib/openmensa --shell /bin/bash openmensa
  chown openmensa:openmensa /var/log/openmensa /mnt/www
EOF

USER openmensa

EXPOSE 3000

VOLUME /mnt/www

ENTRYPOINT [ "/opt/openmensa/entrypoint.sh" ]
CMD [ "server" ]
