defmodule GhIssuesContributors.Domain.ProcessRequest do
  alias GhIssuesContributors.Adapters.WebhookSite.Service, as: Webhook
  alias GhIssuesContributors.Adapters.Github.Service, as: Github

  require Logger

  @moduledoc """
  Módulo responsável por processar as issues e contribuições de um repositório do GitHub.

  Este módulo realiza a seguinte sequência de operações:
  1. Busca as issues e contribuintes de um repositório GitHub.
  2. Se os dados forem encontrados com sucesso, armazena os dados em cache e envia um webhook com o resultado.
  3. Se ocorrer um erro ao buscar os dados, armazena a falha em cache e envia um webhook com uma mensagem de erro.

  ## Funções

    - `process_issues_and_contributors/4`: Processa as issues e contribuições de um repositório, faz o cache dos dados e envia a resposta via webhook.
  """

  require Logger

  @doc """
  Processa as issues e contribuições de um repositório GitHub.

  Esta função realiza as seguintes etapas:
  1. Busca as issues e contribuições do repositório no GitHub.
  2. Se os dados forem encontrados com sucesso, os armazena em cache e envia um webhook.
  3. Se ocorrer um erro na busca, armazena uma falha em cache e envia um webhook com a mensagem de erro.

  ## Parâmetros
    - `owner` (string): O dono do repositório GitHub.
    - `repo` (string): O nome do repositório GitHub.
    - `id_webhook` (string): O identificador do webhook para enviar a resposta.
    - `key` (string): A chave para o cache.

  ## Retorno
  - `:ok` se o processo for bem-sucedido.
  - `{:error, reason}` caso ocorra um erro.
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
