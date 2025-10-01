# Use Ruby base image
FROM ruby:3.2

# Install system dependencies (build tools + Node.js + PostgreSQL client)
RUN apt-get update -qq && \
    apt-get install -y build-essential curl postgresql-client nodejs npm

WORKDIR /app

# Copy Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --without development test

# Copy the rest of the application
COPY . .

# Precompile Rails assets for production (if sprockets is used)
RUN RAILS_ENV=production bundle exec rails assets:precompile || echo "No assets to precompile"

EXPOSE 3000

# Run Puma web server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
