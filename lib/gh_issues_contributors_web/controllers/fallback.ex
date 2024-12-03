defmodule GhIssuesContributorsWeb.Fallback do
  @moduledoc false

  use GhIssuesContributorsWeb, :controller

  alias GhIssuesContributorsWeb.ErrorView

  def call(conn, nil) do
    call(conn, {:error, :not_found})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("error.json", reason: gettext("The item you requested doesn't exist"))
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(ErrorView)
    |> render("error.json", reason: gettext("Access Denied"))
  end

  def call(conn, {:error, :timeout}) do
    conn
    |> put_status(:request_timeout)
    |> put_view(ErrorView)
    |> render("error.json", reason: gettext("Request timeout"))
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("error.json", reason: reason)
  end
end
