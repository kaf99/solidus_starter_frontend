# Use Ruby base image
FROM ruby:3.2

# Install dependencies (adds Yarn for Vite builds)
RUN apt-get update -qq && \
    apt-get install -y build-essential curl postgresql-client && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && \
    bundle install --without development test

COPY . .

# Build JS assets (Vite)
RUN yarn install --frozen-lockfile && \
    RAILS_ENV=production bundle exec vite build

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
