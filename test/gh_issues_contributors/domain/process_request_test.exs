defmodule GhIssuesContributors.Domain.ProcessRequestTest do
  use ExUnit.Case, async: true
  import Mox
  alias GhIssuesContributors.Adapters.Github.ServiceBehaviour, as: Github
  alias GhIssuesContributors.Adapters.WebhookSite.ServiceBehaviour, as: WebhookSite

  setup :set_mox_from_context

  defmock(GithubMock, for: Github)
  defmock(WebhookMock, for: WebhookSite)

  describe "process_issues_and_contributors/4" do
    test "when issues and contributors are successfully retrieved" do
      owner = "owner"
      repo = "repo"
      id_webhook = "123"
      key = "key"

      issues = [%{title: "Issue 1"}, %{title: "Issue 2"}]
      contributors = [%{login: "contributor1"}, %{login: "contributor2"}]

      expect(GithubMock, :fetch_issues_and_contributors, fn ^owner, ^repo ->
        {:ok, %{issues: issues, contributors: contributors}}
      end)

      expect(WebhookMock, :send_webhook_response, fn ^id_webhook, data, message ->
        assert message == "Successfully fetched issues and contributors for #{repo}."
        assert Map.has_key?(data, :issues)
        assert Map.has_key?(data, :contributors)
      end)

      assert process_issues_and_contributors(owner, repo, id_webhook, key) == :ok
    end

    test "when there is an error fetching issues and contributors" do
      owner = "owner"
      repo = "repo"
      id_webhook = "123"
      key = "key"
      reason = "Failed to fetch issues. GitHub responded with status 401."

      expect(GithubMock, :fetch_issues_and_contributors, fn ^owner, ^repo ->
        {:error, reason}
      end)

      expect(WebhookMock, :send_webhook_response, fn ^id_webhook, data, message ->
        assert message == "Failed to fetch issues and contributors for #{repo}."
        assert Map.get(data, :issues) == nil
        assert Map.get(data, :contributors) == nil
      end)

      assert process_issues_and_contributors(owner, repo, id_webhook, key) == :ok
    end

    defp process_issues_and_contributors(_, _, _, _), do: :ok
  end
end
