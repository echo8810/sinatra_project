FROM ruby:2.7-slim
WORKDIR /app
RUN apt-get update && apt-get install -y \
  build-essential \
  libmariadb-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle config --local set path 'vendor/bundle'
RUN bundle install

CMD bundle exec rerun index.rb