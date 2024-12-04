defmodule GhIssuesContributors.Adapters.WebhookSite.Service do
  require Logger

  # Define o tempo de timeout para a requisição e o recebimento de dados.
  @timeout 30_000
  @recv_timeout 30_000

  @moduledoc """
  Módulo responsável por enviar respostas para o Webhook via HTTP.

  Este módulo utiliza a biblioteca `HTTPoison` para enviar dados para um webhook
  fornecido, com um tempo de timeout configurado para evitar que a aplicação
  fique bloqueada indefinidamente esperando pela resposta.

  ## Funções

    - `send_webhook_response/3`: Envia dados para um webhook via requisição HTTP POST.
  """

  @doc """
  Envia dados para um webhook via requisição HTTP POST.

  Esta função envia os dados para a URL do webhook, passando um payload JSON e
  definindo os headers apropriados. O tempo de timeout da requisição e o tempo
  de espera para o recebimento da resposta são configurados conforme os valores
  definidos no módulo.

  ## Parâmetros

    - `id` (string): O identificador único do webhook, usado para construir a URL.
    - `data` (map): Os dados que serão enviados no corpo da requisição, que são codificados como JSON.
    - `log_message` (string): A mensagem a ser registrada nos logs em caso de sucesso.

  ## Retorno
    - Em caso de sucesso (`{:ok, %HTTPoison.Response{status_code: 200}}`), a função registra uma mensagem de log informando o sucesso.
    - Em caso de erro, um log de erro é registrado com a razão do erro.
  """
  def send_webhook_response(id, data, log_message) do
    webhook_url = "#{System.get_env("SITE_WEBHOOK", "https://webhook.site")}/#{id}"

    options = [
      timeout: @timeout,
      recv_timeout: @recv_timeout
    ]

    case HTTPoison.post(webhook_url, Jason.encode!(data), [{"Content-Type", "application/json"}], options) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info(log_message)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Failed to send data to webhook: #{reason}")
    end
  end
end
