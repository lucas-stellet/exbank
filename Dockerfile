# Use an official Elixir runtime as a parent image.
FROM elixir:1.14.5-otp-25

RUN apt-get update && \
  apt-get install -y postgresql-client

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install Hex package manager.
RUN mix local.hex --force

# Compile the project.
RUN mix local.rebar --force && mix deps.get && mix deps.compile

ENTRYPOINT  ["sh", "/app/entrypoint.sh"]

