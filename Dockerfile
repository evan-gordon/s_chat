FROM elixir:latest
LABEL Name=s_chat Version=0.0.1

ENV MIX_ENV=prod

# Mkdir for ap and copy project into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex
RUN mix local.hex --force
RUN mix do compile
