defmodule GhIssuesContributors.Domain.ProcessRequest do
  @moduledoc """
  Module responsible for processing issues and contributors from a GitHub repository.

  This module performs the following sequence of operations:
  1. Fetches the issues and contributors of a GitHub repository.
  2. If the data is successfully retrieved, it caches the data and sends a webhook with the result.
  3. If an error occurs while fetching the data, it caches the failure and sends a webhook with an error message.

  ## Functions

    - `process_issues_and_contributors/4`: Processes the issues and contributions of a repository, caches the data, and sends the response via webhook.

  ## Example

      GhIssuesContributors.Domain.ProcessRequest.process_issues_and_contributors(
        "owner_name", "repository_name", "webhook_id", "cache_key"
      )

  """

  alias GhIssuesContributors.Adapters.Github.Service, as: Github
  alias GhIssuesContributors.Jobs.SendWebhookDelayed
  require Logger

  @doc """
  Processes the issues and contributions of a GitHub repository.

  This function performs the following steps:
  1. Fetches the repository's issues and contributors from GitHub.
  2. If the data is successfully retrieved, it caches the data and sends a webhook with the results.
  3. If an error occurs during the fetch, it caches the failure and sends a webhook with an error message.

  ## Parameters
    - `owner` (string): The owner of the GitHub repository (e.g., `"octocat"`).
    - `repo` (string): The name of the GitHub repository (e.g., `"hello-world"`).
    - `id_webhook` (string): The identifier for the webhook to send the response.
    - `key` (string): The key used for caching the data.

  ## Return
    - `:ok` if the process is successful, meaning the data was fetched and the webhook was sent.
    - `{:error, reason}` if an error occurs, meaning the issues and contributors could not be fetched.

  ## Example

      process_issues_and_contributors("octocat", "hello-world", "webhook_123", "cache_key")
  """
  def process_issues_and_contributors(owner, repo, id_webhook, key) do
    Logger.info("[ProcessRequest] Starting to process issues and contributors for repository #{repo}.")

    case Github.fetch_issues_and_contributors(owner, repo) do
      {:ok, %{issues: issues, contributors: contributors}} ->
        # Data retrieved successfully, process it
        data = build_data(owner, repo, issues, contributors)
        message = "Successfully fetched issues and contributors for #{repo}"

        # Cache the success data
        RememberMe.guard(key, %{data: data, message: message, id_webhook: id_webhook}, min: get_cache_time())

        # Schedule the webhook job
        %{
          id_webhook: id_webhook,
          data: data,
          message: message
        }
        |> SendWebhookDelayed.new(schedule_in: Application.get_env(:gh_issues_contributors, :delay))
        |> Oban.insert()

        Logger.info("[ProcessRequest] Issues and contributors for #{repo} successfully processed and sent to the webhook.")

      {:error, reason} ->
        # Failed to fetch data, process failure
        error_data = build_error_data(owner, repo, reason)
        message = "Failed to fetch issues and contributors for #{repo}"

        # Cache the error data
        RememberMe.guard(key, %{data: error_data, message: message, id_webhook: id_webhook}, min: get_cache_time())

        # Schedule the error webhook job
        %{
          id_webhook: id_webhook,
          data: error_data,
          message: message
        }
        |> SendWebhookDelayed.new(schedule_in: Application.get_env(:gh_issues_contributors, :delay))
        |> Oban.insert()

        Logger.error("[ProcessRequest] Failed to fetch issues and contributors for #{repo}: #{inspect(reason)}")
    end
  end

  defp build_data(owner, repo, issues, contributors) do
    %{
      user: owner,
      repository: repo,
      issues: issues,
      contributors: contributors
    }
  end

  defp build_error_data(owner, repo, reason) do
    %{
      user: owner,
      repository: repo,
      issues: nil,
      contributors: nil,
      message: "Failed to fetch issues and contributors: #{reason}"
    }
  end

  defp get_cache_time do
    String.to_integer(System.get_env("CACHED_DATA_MIN", "5"))
  end
end
