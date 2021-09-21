FROM elixir:1.12-alpine

WORKDIR /ex_double_entry

RUN set -ex; \
    apk add --no-cache \
        build-base \
        git \
        mariadb-dev \
        postgresql-dev \
        ;

RUN mix local.hex --force && \
    mix local.rebar --force

COPY . ./

ENV MIX_ENV=test

RUN mix do deps.get, deps.compile
