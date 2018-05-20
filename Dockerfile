FROM ruby:2.5.1-alpine3.7

WORKDIR /phraselog_api

COPY Gemfile Gemfile.lock ./

RUN apk --no-cache --virtual .gem-builddeps add \
    build-base \
    linux-headers \
    mariadb-dev \
 && bundle install \
 && apk del .gem-builddeps \
 && apk --no-cache add \
    tzdata \
    mariadb-client-libs

COPY . .

ARG RAILS_ENV
ARG SECRET_KEY_BASE
ARG DATABASE_URL

RUN rails db:create \
 && rails db:migrate

CMD ["rails", "server"]
