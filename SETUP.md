# Setting Up Your Dev Environment

## Packages you'll need installed

* elixir
* phoenix
* postgres or `psql`
* `npm`
* inotify-tools: <https://github.com/rvoicilas/inotify-tools/wiki>

## Getting things Running

* Install npm packages: `cd assets/ && npm install`
* Create and migrate your DB: `mix ecto.create && mix ecto.migrate`
* Install project dependencies: `mix deps.get`
