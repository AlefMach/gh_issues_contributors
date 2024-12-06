defmodule GhIssuesContributors.Repo do
  use Ecto.Repo,
    otp_app: :gh_issues_contributors,
    adapter: Ecto.Adapters.Postgres
end
