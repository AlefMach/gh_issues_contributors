defmodule GhIssuesContributors.Domain.ProcessRequest do
  @moduledoc """
  Module responsible for processing issues and contributions from a GitHub repository.

  This module performs the following sequence of operations:
  1. Fetches the issues and contributors of a GitHub repository.
  2. If the data is successfully retrieved, it caches the data and sends a webhook with the result.
  3. If an error occurs while fetching the data, it caches the failure and sends a webhook with an error message.

  ## Functions

    - `process_issues_and_contributors/4`: Processes the issues and contributions of a repository, caches the data, and sends the response via webhook.
  """

  alias GhIssuesContributors.Adapters.WebhookSite.Service, as: Webhook
  alias GhIssuesContributors.Adapters.Github.Service, as: Github
  require Logger

  @doc """
  Processes the issues and contributions of a GitHub repository.

  This function performs the following steps:
  1. Fetches the repository's issues and contributions from GitHub.
  2. If the data is successfully retrieved, it caches the data and sends a webhook.
  3. If an error occurs during the fetch, it caches the failure and sends a webhook with an error message.

  ## Parameters
    - `owner` (string): The owner of the GitHub repository.
    - `repo` (string): The name of the GitHub repository.
    - `id_webhook` (string): The identifier of the webhook to send the response.
    - `key` (string): The key for caching.

  ## Return
    - `:ok` if the process is successful.
    - `{:error, reason}` if an error occurs.
  """
  def process_issues_and_contributors(owner, repo, id_webhook, key) do
    Logger.info("[ProcessRequest] Iniciando o processamento das issues e contribuições para o repositório #{repo}.")

    case Github.fetch_issues_and_contributors(owner, repo) do
      {:ok, %{issues: issues, contributors: contributors}} ->
        data = %{
          user: owner,
          repository: repo,
          issues: issues,
          contributors: contributors
        }

        min = String.to_integer(System.get_env("CACHED_DATA", "5"))
        message = "Successfully fetched issues and contributors for #{repo}."

        RememberMe.guard(key, %{data: data, message: message, id_webhook: id_webhook}, min: min)

        Webhook.send_webhook_response(id_webhook, data, message)

        Logger.info("[ProcessRequest] Issues e contribuições para #{repo} processadas com sucesso e enviadas para o webhook.")

      {:error, reason} ->
        error_data = %{
          user: owner,
          repository: repo,
          issues: nil,
          contributors: nil,
          message: "Failed to fetch issues and contributors: #{reason}"
        }

        min = String.to_integer(System.get_env("CACHED_DATA", "5"))
        message = "Failed to fetch issues and contributors for #{repo}."

        RememberMe.guard(key, %{data: error_data, message: message, id_webhook: id_webhook}, min: min)

        Webhook.send_webhook_response(id_webhook, error_data, message)

        Logger.error("[ProcessRequest] Falha ao buscar issues e contribuições para #{repo}: #{reason}")
    end
  end
end
