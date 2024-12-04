defmodule GhIssuesContributorsWeb.Plugs.AuthHeaderCheck do
  @moduledoc """
  A Plug to validate the presence of the `X-GH-AUTH` and `X-ID-WEBHOOK` headers in incoming requests.

  This plug ensures that both headers are present. If either header is missing,
  the plug returns a 401 Unauthorized response and halts further processing. If both headers
  are present, the request continues through the pipeline.

  ## Logging
  - Logs a warning when any of the headers (`X-GH-AUTH`, `X-ID-WEBHOOK`) is missing.
  - Logs info messages when both headers are present, including their values.

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

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  @doc """
  Validates the presence of the `X-GH-AUTH` and `X-ID-WEBHOOK` headers in the request.

  - If any of the headers are missing, it logs a warning and responds with a 401 status.
  - If both headers are present, it logs their values and allows the request to proceed.

  ## Parameters
  - `conn`: The current `Plug.Conn` struct representing the request.
  - `_opts`: Options for the plug (currently unused).

  ## Returns
  - The modified `Plug.Conn` struct. If any header is missing, the connection is halted.
  """
  def call(conn, _opts) do
    auth_header = get_req_header(conn, "x-gh-auth")
    webhook_header = get_req_header(conn, "x-id-webhook")

    cond do
      auth_header == [] ->
        Logger.warning("[AuthHeaderCheck] Missing X-GH-AUTH header.")
        conn
        |> send_resp(401, "Missing X-GH-AUTH header")
        |> halt()

      webhook_header == [] ->
        Logger.warning("[AuthHeaderCheck] Missing X-ID-WEBHOOK header.")
        conn
        |> send_resp(401, "Missing X-ID-WEBHOOK header")
        |> halt()

      true ->
        Logger.info("[AuthHeaderCheck] Found X-GH-AUTH header: #{hd(auth_header)}.")
        Logger.info("[AuthHeaderCheck] Found X-ID-WEBHOOK header: #{hd(webhook_header)}.")
        conn
    end
  end
end
