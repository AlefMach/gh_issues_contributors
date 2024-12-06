defmodule GhIssuesContributors.Adapters.WebhookSite.Service do
  @moduledoc """
  Module responsible for sending HTTP requests to a webhook.

  This module uses the `HTTPoison` library to send data to a given webhook URL. It ensures that the application does not get indefinitely blocked while waiting for a response by configuring both the request timeout and the response timeout.

  ## Functionality:
    - Sends HTTP POST requests to a webhook URL with a JSON payload.
    - Configures the timeouts for both the request and response.
    - Logs the outcome (success or failure) of each request.

  ## Configuration:
    - `@timeout`: The timeout for the HTTP request in milliseconds (default is 30,000 ms).
    - `@recv_timeout`: The timeout for receiving the response in milliseconds (default is 30,000 ms).

  ## Example Usage:
      GhIssuesContributors.Adapters.WebhookSite.Service.send_webhook_response("webhook-id", %{"key" => "value"}, "Successfully sent webhook")
  """

  require Logger

  @timeout 60_000
  @recv_timeout 60_000

  @behaviour GhIssuesContributors.Adapters.WebhookSite.ServiceBehaviour

  @doc """
  Sends data to a webhook via an HTTP POST request.

  This function constructs the webhook URL using the `id`, encodes the `data` as JSON, and sends it with the appropriate HTTP headers. The timeouts for the request and the response are configured as per the module's settings.

  ## Parameters:
    - `id` (string): The unique identifier of the webhook, used to build the full webhook URL.
    - `data` (map): The data to be sent in the body of the POST request. It will be encoded as JSON.
    - `log_message` (string): The message to log upon success, indicating what was sent to the webhook.

  ## Returns:
    - `:ok` if the request was successful and the status code is 200.
    - `{:error, :non_200_status_code}` if the webhook returns a status code other than 200.
    - `{:error, reason}` if there was an error in sending the request (e.g., network failure or timeout).

  ## Logging:
    - Logs a success message when the webhook is sent with a 200 status code.
    - Logs an error message if the status code is not 200 or if the request fails due to an error.
  """
  def send_webhook_response(id, data, log_message) do
    # Construct the full URL for the webhook
    webhook_url = "#{System.get_env("SITE_WEBHOOK", "https://webhook.site")}/#{id}"

    # Configure timeouts for the request and response
    options = [
      timeout: @timeout,
      recv_timeout: @recv_timeout
    ]

    # Make the HTTP POST request
    case HTTPoison.post(webhook_url, Jason.encode!(data), [{"Content-Type", "application/json"}], options) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Webhook sent successfully: #{log_message}")
        :ok

      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code != 200 ->
        Logger.error("Failed to send webhook (status: #{status_code}): #{log_message}")
        {:error, :non_200_status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Failed to send data to webhook: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
