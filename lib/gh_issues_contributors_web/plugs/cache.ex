defmodule GhIssuesContributorsWeb.Plugs.Cache do
  @moduledoc """
  A Plug for caching API responses using `RememberMe`.

  This plug checks if a response for the current request exists in the cache.
  If a cached response is found, it is sent immediately; otherwise, the request continues to the next plug/controller.

  ## Functionality:
    - Fetches a cache key based on the current request using `Utils.cache_key/1`.
    - Checks for cached data with `RememberMe.find_value/1`.
    - Serializes the cached data before sending it as a response.

  ## Logging:
    Logs cache hits and misses for monitoring purposes.
  """

  import Plug.Conn
  alias GhIssuesContributorsWeb.Utils
  alias Jason
  alias GhIssuesContributors.Adapters.WebhookSite.Service, as: Webhook
  require Logger

  @spec init(any()) :: any()
  @doc """
  Initializes the plug with the given options.

  Currently, no specific options are used.
  """
  def init(default), do: default

  @doc """
  Processes the connection to check for cached responses.

  - If cached data exists, it logs a cache hit, serializes the data, and sends it as a response.
  - If no cached data is found, logs a cache miss and passes the connection through.

  ## Parameters
  - `conn`: The current `Plug.Conn` connection.
  - `_opts`: Options for the plug (currently unused).

  ## Returns
  - The modified connection, either halted (if cache hit) or untouched (if cache miss).
  """
  def call(conn, _opts) do
    cache_key = Utils.cache_key(conn)
    Logger.info("[Plugs.Cache] Checking cache for key: #{cache_key}")

    case RememberMe.find_value(cache_key) do
      nil ->
        Logger.info("[Plugs.Cache] Cache miss for key: #{cache_key}")
        conn

      %{data: data, message: message, id_webhook: id_webhook} ->
        Logger.info("[Plugs.Cache] Cache hit for key: #{cache_key}. Returning cached response.")

        Task.start(fn -> Webhook.send_webhook_response(id_webhook, data, message) end)

        conn
        |> send_resp(202, "Processing started")
        |> halt()
    end
  end
end
