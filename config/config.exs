# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :gh_issues_contributors,
  generators: [timestamp_type: :utc_datetime]

config :gh_issues_contributors,
  ecto_repos: [GhIssuesContributors.Repo],
  generators: [timestamp_type: :utc_datetime]

config :gh_issues_contributors, Oban,
  repo: GhIssuesContributors.Repo,
  queues: [webhook: 10]

# Configures the endpoint
config :gh_issues_contributors, GhIssuesContributorsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: GhIssuesContributorsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GhIssuesContributors.PubSub,
  live_view: [signing_salt: "OMmoivLl"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :gh_issues_contributors, GhIssuesContributors.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
