# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :exbank,
  ecto_repos: [Exbank.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :exbank, ExbankWeb.Endpoint,
  url: [host: "0.0.0.0"],
  render_errors: [
    formats: [json: ExbankWeb.ErrorJSON],
    layout: false
  ],
  # pubsub_server: Exbank.PubSub,
  live_view: [signing_salt: "Y65w9fbY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian Configuration
config :exbank, Exbank.Guardian,
  issuer: "exbank",
  ttl: {60, :minutes}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
