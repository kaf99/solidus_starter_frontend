# Use your existing Ruby version
ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-buster

# System dependencies
ARG NODE_VERSION
ARG BUNDLER_VERSION

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential curl git nodejs npm postgresql-client default-mysql-client \
    libsqlite3-dev chromium chromium-driver libvips imagemagick sqlite3 \
  && rm -rf /var/lib/apt/lists/*

# User setup
ENV APP_USER=solidus_starter_frontend_user
ENV APP_HOME=/home/$APP_USER/app
ENV GEM_HOME=/home/$APP_USER/gems
ENV PATH=$PATH:$GEM_HOME/bin

RUN useradd -ms /bin/bash $APP_USER
RUN gem update --system && gem install bundler:$BUNDLER_VERSION
USER $APP_USER

WORKDIR $APP_HOME

# Copy app and install gems
COPY --chown=$APP_USER:$APP_USER Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY --chown=$APP_USER:$APP_USER . ./

# Install JS dependencies if using jsbundling/webpacker
RUN if [ -f package.json ]; then npm install; fi

# Precompile assets if Rails asset pipeline exists
RUN if bundle exec rake -T | grep -q assets:precompile; then \
      RAILS_ENV=production bundle exec rake assets:precompile; \
    else \
      echo "No assets to precompile"; \
    fi

EXPOSE 3000

# Run Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
