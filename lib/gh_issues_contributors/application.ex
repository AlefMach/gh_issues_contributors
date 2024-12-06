defmodule GhIssuesContributors.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GhIssuesContributorsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:gh_issues_contributors, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GhIssuesContributors.PubSub},
      GhIssuesContributors.Repo,
      # Start the Finch HTTP client for sending emails
      {Finch, name: GhIssuesContributors.Finch},
      {Oban, Application.fetch_env!(:gh_issues_contributors, Oban)},
      # Start a worker by calling: GhIssuesContributors.Worker.start_link(arg)
      # {GhIssuesContributors.Worker, arg},
      # Start to serve requests, typically the last entry
      GhIssuesContributorsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GhIssuesContributors.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GhIssuesContributorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
