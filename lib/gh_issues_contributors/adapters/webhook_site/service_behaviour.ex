defmodule GhIssuesContributors.Adapters.WebhookSite.ServiceBehaviour do
  @callback send_webhook_response(String.t(), map(), String.t()) :: :ok | {:error, String.t()}
end
