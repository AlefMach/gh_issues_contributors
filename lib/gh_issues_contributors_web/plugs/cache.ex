defmodule GhIssuesContributorsWeb.Plugs.Cache do
  @moduledoc """
  A Plug for caching API responses using `RememberMe`.

  This plug checks if a response for the current request exists in the cache.
  If a cached response is found, it is sent immediately; otherwise, the request continues to the next plug or controller.

  ## Functionality:
    - Fetches a cache key based on the current request using `Utils.cache_key/1`.
    - Checks for cached data with `RememberMe.find_value/1`.
    - If cached data is found, the response is sent immediately with status 202 (Accepted), and the job is scheduled asynchronously.
    - If no cached data is found, the request proceeds normally.

  ## Logging:
    - Logs cache hits and misses for monitoring purposes.
    - Logs whether a request is processed from cache or passed through to the next plug/controller.

  ## Example Usage:

      # In your router or controller
      plug GhIssuesContributorsWeb.Plugs.Cache
  """

  import Plug.Conn
  alias GhIssuesContributorsWeb.Utils
  alias GhIssuesContributors.Jobs.SendWebhookDelayed
  require Logger

  @spec init(any()) :: any()
  @doc """
  Initializes the plug with the given options.

  Currently, no specific options are used.

  ## Parameters:
    - `default`: The default options passed to the plug (currently unused).

  ## Returns:
    - The same `default` value, which is the default behavior for initialization.
  """
  def init(default), do: default

  @doc """
  Processes the connection to check for cached responses.

  - If cached data exists:
    - Logs a cache hit.
    - Schedules a background job to process the cached data asynchronously.
    - Responds with a 202 (Accepted) status and a "Processing started" message.

  - If no cached data is found:
    - Logs a cache miss and proceeds with the request.

  ## Parameters:
    - `conn`: The current `Plug.Conn` connection.
    - `_opts`: Options for the plug (currently unused).

  ## Returns:
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

        Task.start(fn -> schedule_job(id_webhook, data, message) end)

        conn
        |> send_resp(202, "Processing started")
        |> halt()
    end
  end

  defp schedule_job(id_webhook, data, message) do
    changeset = SendWebhookDelayed.new(%{
      id_webhook: id_webhook,
      data: data,
      message: message
    })

    SendWebhookDelayed
    |> Oban.insert(changeset, schedule_in: Application.get_env(:gh_issues_contributors, :delay))
  end
end
