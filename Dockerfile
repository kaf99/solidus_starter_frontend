# — start of file —

# Use Ruby base image
FROM ruby:3.2

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && \
    bundle install --without development test

COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# — end of file —
