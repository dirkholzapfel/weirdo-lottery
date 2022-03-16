import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weirdo_lottery, WeirdoLotteryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "IYZLqB2P49iHb/d/IlrbDTA5i9G94XmWaDwoIptmpOPLtAGiuqIntJPWnc6Jfayl",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your local test database in this file. If it does not exist yet
# copy and configure database.test.exs.sample
import_config "database.test.exs"
