defmodule GhIssuesContributorsWeb.HealthCheckController do
  use GhIssuesContributorsWeb, :controller

  @spec check(any, map) :: map
  def check(conn, _params) do
    with {:ok, status} <- {:ok, 200} do # Change for search in database
      json(conn, status)
    end
  end
end
