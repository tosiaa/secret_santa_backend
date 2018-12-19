# SecretSanta

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Setup environment variables:
  - HOST
  - PORT
  - ICO_SECRET_KEY_BASE: can be generated with `miz phx.gen.secret`
  - ICO_GUARDIAN_SECRET_KEY: can be generated with `mix phx.gen.secret`
  - ICO_FM_API_KEY
  - ICO_FM_API_SECRET
  - ICO_FM_LIST_KEY
  - DATABASE_URL
  - SMTP_SERVER
  - SMTP_HOSTNAME
  - SMTP_PORT
  - SMTP_USERNAME
  - SMTP_PASSWORD
  - set REPLACE_OS_VARS to true if running in docker
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To deploy:

- Place built static files at `priv/static`
- Bump version in `mix.exs`
- Run `MIX_ENV=prod mix dockerate release`
- Login to registry: `docker login registry.swmansion.com`
- Run `docker push registry.swmansion.com/bitwin/ico-backend:VERSION`
