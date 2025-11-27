import Config

config :awesome_dashboard, AwesomeDashboard.Repo,
  database: Path.join(__DIR__, "../path/to/your#{System.get_env("MIX_TEST_PARTITION")}.db"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :ash, policies: [show_policy_breakdowns?: true], disable_async?: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awesome_dashboard, AwesomeDashboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8DE7E1/Zkn5JJxE1q2Nr4jQ+qEi60gVOVoBJZ7FP6V54fp2tK+qFSrE3afwzkFcT",
  server: false

# In test we don't send emails
config :awesome_dashboard, AwesomeDashboard.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
