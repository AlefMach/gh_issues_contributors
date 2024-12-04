defmodule GhIssuesContributorsWeb.Plugs.AuthHeaderCheck do
  @moduledoc """
  A Plug to validate the presence of the `X-GH-AUTH` header in incoming requests.

  This plug ensures that all requests contain the `X-GH-AUTH` header. If the header is missing,
  the plug returns a 401 Unauthorized response and halts further processing. If the header is
  present, the request continues through the pipeline.

  ## Logging
  - Logs a warning when the `X-GH-AUTH` header is missing.
  - Logs an info message when the `X-GH-AUTH` header is present, including its value.

  ## Example Usage
  Add the plug to a pipeline in your router:

      pipeline :api do
        plug :accepts, ["json"]
        plug GhIssuesContributorsWeb.Plugs.AuthHeaderCheck
      end
  """

  import Plug.Conn
  require Logger

  @doc """
  Initializes the plug with the given options.

  Currently, no specific options are used.
  """
  def init(default), do: default

  @doc """
  Validates the presence of the `X-GH-AUTH` header in the request.

  - If the header is missing, it logs a warning and responds with a 401 status.
  - If the header is present, it logs the value and allows the request to proceed.

  ## Parameters
  - `conn`: The current `Plug.Conn` struct representing the request.
  - `_opts`: Options for the plug (currently unused).

  ## Returns
  - The modified `Plug.Conn` struct. If the header is missing, the connection is halted.
  """
  def call(conn, _opts) do
    case get_req_header(conn, "x-gh-auth") do
      [] ->
        Logger.warning("[AuthHeaderCheck] Missing X-GH-AUTH header.")
        conn
        |> send_resp(401, "Missing X-GH-AUTH header")
        |> halt()

      [auth_header] ->
        Logger.info("[AuthHeaderCheck] Found X-GH-AUTH header: #{auth_header}.")
        conn
    end
  end
end
