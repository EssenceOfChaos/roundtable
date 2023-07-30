# Roundtable

[![.github/workflows/elixir.yml](https://github.com/EssenceOfChaos/roundtable/actions/workflows/elixir.yml/badge.svg)](https://github.com/EssenceOfChaos/roundtable/actions/workflows/elixir.yml)

**TODO: Add description**

## System Requirements

- Install Erlang `brew install erlang`
- Install Elixir `brew install elixir`
- Install Hex package manager: `mix local.hex`
- Install dependencies with `mix deps.get`

## Instructions

After pulling down the dependencies with `mix deps.get` run `docker compose up -d` to stand up a mongodb container.

Start the application with `iex -S mix` and use curl or Postman to send a GET request to localhost:8080.

To tear down the container run `docker compose down`.

TODO: `docker-compose.yml` not working, currently running mongodb on localhost instead.
