FROM ruby:2.3.7-alpine

RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  && rm -rf /var/cache/apk/*

RUN apk update && apk add 

RUN adduser -S ruby
USER ruby

RUN gem install bundler

WORKDIR $HOME/specs

COPY . .

RUN gem install bundler && bundle install
ENV GREETING='Hello World!'
CMD ["rspec", "--format", "doc"]