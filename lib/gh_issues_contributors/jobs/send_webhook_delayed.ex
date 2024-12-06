defmodule GhIssuesContributors.Jobs.SendWebhookDelayed do
  # Defines the module as an Oban Worker, which will be placed in the :webhook queue and will have a maximum of 3 attempts.
  use Oban.Worker, queue: :webhook, max_attempts: 3

  # Requires the Logger to log success and error messages
  require Logger

  # Alias for easy access to the `send_webhook_response` function in the WebhookSite.Service module
  alias GhIssuesContributors.Adapters.WebhookSite.Service, as: Webhook

  @impl Oban.Worker
  # The `perform/1` function is called when the job is executed by Oban. It receives the job and its parameters.
  #
  # Arguments:
  #   - `%Oban.Job{args: %{"id_webhook" => id_webhook, "data" => data, "message" => message}}`
  #
  # Inside the Job, the parameters `id_webhook`, `data`, and `message` are extracted and passed to the
  # `send_webhook_response/3` function from the Webhook module.
  #
  # It returns `:ok` if the webhook is successfully sent, or an error if something goes wrong.
  #
  # Return:
  #   - `:ok` if the webhook was sent successfully.
  #   - `{:error, reason}` if an error occurred, causing Oban to retry after 5 seconds.

  def perform(%Oban.Job{args: %{"id_webhook" => id_webhook, "data" => data, "message" => message}}) do
    case Webhook.send_webhook_response(id_webhook, data, message) do
      :ok ->
        Logger.info("[SendWebhookDelayed] - data: #{IO.inspect(data)} sent with success - id_webhook: #{id_webhook}")
        :ok

      {:error, reason} ->
        Logger.error("[SendWebhookDelayed] - Error sending webhook: #{inspect(reason)}")
        {:retry, 5000}
    end
  end
end
