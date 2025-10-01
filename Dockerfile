# Use official Ruby image (adjust if your Gemfile requires older Ruby)
FROM ruby:3.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs postgresql-client

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfiles first for better caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --without development test

# Copy the application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the Rails server with Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
