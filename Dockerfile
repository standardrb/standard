FROM ruby:2.5

RUN mkdir /gem
WORKDIR /gem

COPY Gemfile Gemfile.lock standard.gemspec ./
COPY lib/standard/version.rb ./lib/standard/

RUN bundle install --jobs 8

ADD . /gem/
