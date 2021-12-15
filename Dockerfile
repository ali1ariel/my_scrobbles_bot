FROM elixir:latest AS builder

RUN apt-get update && \
    apt-get install -y postgresql-client

RUN mkdir /app
COPY . /app
WORKDIR /app

# ENV MIX_ENV=prod
# This step installs all the build tools

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

RUN mix do local.rebar --force, local.hex --force


# Compiling Elixir
RUN mix do deps.get, deps.compile, compile

# Compiling Javascript
RUN cd assets \
    && npm rebuild node-sass \
    && npm install \
    && ./node_modules/webpack/bin/webpack.js --mode production \
    && cd .. \
    && mix phx.digest

# Build Release
# RUN mkdir -p /opt/release \
#     && mix release \
#     && mv _build/${MIX_ENV}/rel/kirby_project /opt/release

RUN mix do compile

CMD ["/app/entrypoint.sh"]