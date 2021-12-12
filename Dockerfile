FROM ruby:2.5.1

ENV TZ Asia/Tokyo

RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY ./suzukitsukurepo/Gemfile /app/Gemfile
COPY ./suzukitsukurepo/Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY ./suzukitsukurepo /app


CMD RAILS_RELATIVE_URL_ROOT=/suzukitsukurepo bundle exec rails s -b 0.0.0.0
