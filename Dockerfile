FROM ruby:3.1.2-alpine as builder

RUN bundle config --global frozen 1 && \
    bundle config set without 'test development' && \
    apk add --no-cache --update build-base tzdata yarn openssl mysql-dev git
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install --jobs=4
ENV RAILS_ENV=production
COPY . /app/

RUN mkdir -p /app/storage
WORKDIR /app

ENTRYPOINT ["sh","-e","entrypoint.sh"]
