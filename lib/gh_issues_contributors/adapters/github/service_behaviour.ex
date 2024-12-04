defmodule GhIssuesContributors.Adapters.Github.ServiceBehaviour do
  @callback fetch_issues_and_contributors(String.t(), String.t()) ::
              {:ok, %{issues: list(), contributors: list()}} | {:error, String.t()}
end
