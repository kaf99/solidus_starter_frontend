# Use Ruby base image
FROM ruby:3.2

# Install system dependencies (Ruby build tools, PostgreSQL client, Node.js, Yarn v1)
RUN apt-get update -qq && \
    apt-get install -y build-essential curl postgresql-client && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn@1

WORKDIR /app

# Copy JS dependencies first for better caching
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --without development test

# Copy the rest of the application
COPY . .

# Make sure local node binaries are in PATH (so vite is found)
ENV PATH="/app/node_modules/.bin:$PATH"

# Precompile Vite assets for production
RUN RAILS_ENV=production bundle exec vite build

EXPOSE 3000

# Run Puma web server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
