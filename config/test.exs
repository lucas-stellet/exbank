import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :exbank, Exbank.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "exbank_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exbank, ExbankWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0RRqd5qctqLxujO6Uk5ShwcKiY3Oz0GAAJrOk6ECYSuko/p8QFmblCM90KcFbLaA",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :exbank, Exbank.Guardian,
  secret_key: "gtlrAHxRvLotCZn4D9bZymZuveVVxVgZvBpt8aALH3wB6M6z750FNj/7zs+19kEg"

config :exbank, :teller,
  url: "http://localhost:1200/",
  api_key: "HowManyGenServersDoesItTakeToCrackTheBank?",
  user_agent: "Teller Bank iOS 2.0"

config :exbank, Exbank.Vault, vault_key: "h8ztI/7CJ4Lsq7hTDP5shdUicxY0+kv9JhNq/+YE9FE="
