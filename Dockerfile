FROM ruby:1.9.3-p551
MAINTAINER Leandro David Cacciagioni <leandro.21.2008@gmail.com>

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without test development

COPY . /usr/src/app
EXPOSE 9393
CMD bundle exec "rackup -p 9393"
