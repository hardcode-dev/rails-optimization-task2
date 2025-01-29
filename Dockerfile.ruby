FROM ruby:3.1.0-alpine

RUN apk update  && apk upgrade && apk add --update --no-cache \
  build-base tzdata bash htop valgrind

WORKDIR /opt/app

COPY Gemfile* ./

RUN gem install bundler -v 2.4.7
RUN bundle install

COPY . .
