defmodule GhIssuesContributorsWeb.Utils do
  @moduledoc """
  A utility module for common operations in the GhIssuesContributorsWeb application.

  This module provides helper functions that are used across the application,
  such as generating unique cache keys for requests.
  """

  @spec cache_key(any()) :: <<_::16, _::_*8>>
  @doc """
  Generates a unique cache key for a given request.

  The key is based on the HTTP method, request path, and query string of the connection.
  This ensures that each unique combination of these components produces a distinct key,
  making it suitable for caching purposes.

  The key is generated in lowercase to ensure consistency and prevent case-sensitivity issues.

  ## Parameters
  - `conn`: A `Plug.Conn` struct representing the incoming HTTP request.

  ## Returns
  - A string representing the unique cache key in the format:
    `"method-path-query_string"`, all in lowercase.

  ## Examples

      iex> conn = %Plug.Conn{
      ...>   method: "GET",
      ...>   request_path: "/api/v1/github/repo",
      ...>   query_string: "page=1"
      ...> }
      iex> GhIssuesContributorsWeb.Utils.cache_key(conn)
      "get-/api/v1/github/repo-page=1"

      iex> conn = %Plug.Conn{
      ...>   method: "POST",
      ...>   request_path: "/api/v1/github/repo",
      ...>   query_string: ""
      ...> }
      iex> GhIssuesContributorsWeb.Utils.cache_key(conn)
      "post-/api/v1/github/repo-"
  """
  def cache_key(conn) do
    "#{String.downcase(conn.method)}-#{String.downcase(conn.request_path)}-#{String.downcase(conn.query_string)}"
  end
end
