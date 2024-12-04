defmodule GhIssuesContributors.Adapters.WebhookSite.Service do
  @moduledoc """
  Module responsible for sending responses to the Webhook via HTTP.

  This module uses the `HTTPoison` library to send data to a given webhook, with a configured
  timeout to prevent the application from being indefinitely blocked while waiting for a response.

  ## Functions

    - `send_webhook_response/3`: Sends data to a webhook via an HTTP POST request.
  """
  require Logger

  @timeout 30_000
  @recv_timeout 30_000

  @behaviour GhIssuesContributors.Adapters.WebhookSite.ServiceBehaviour

  @doc """
  Sends data to a webhook via an HTTP POST request.

  This function sends the data to the webhook URL, passing a JSON payload and
  setting the appropriate headers. The request timeout and the response wait time
  are configured according to the values defined in the module.

  ## Parameters

    - `id` (string): The unique identifier of the webhook, used to build the URL.
    - `data` (map): The data to be sent in the request body, encoded as JSON.
    - `log_message` (string): The message to log in case of success.

  ## Return
    - On success (`{:ok, %HTTPoison.Response{status_code: 200}}`), the function logs a success message.
    - On failure, an error log is recorded with the reason for the error.
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
