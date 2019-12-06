# Note that rebuilding the container can result in a newer
# version of apline.  For example you might have 3.10.0
# then 3.10.1 in a future build.
FROM ruby:2.6.5-alpine3.10

# Working directory.
RUN mkdir /app
WORKDIR /app

# build-base: required to build several gems.
# git: required by the Gemspec.
RUN apk update && \
    apk add --no-cache "build-base" \
                       "git"

# Add the code.
COPY . .

# Install the gems.
RUN gem install bundler -v 1.17.3
RUN bundle install