defmodule GhIssuesContributorsWeb.IssuesControllerTest do
  use GhIssuesContributorsWeb.ConnCase, async: false
  use Plug.Test

  alias GhIssuesContributorsWeb.Router

  @opts Router.init([])

  describe "index/2" do
    test "returns 202 when valid owner and repo are provided" do
      conn =
        conn(:get, "/api/v1/github/AlefMach/gh_issues_contributors")
        |> put_req_header("x-gh-auth", "1234")
        |> put_req_header("x-id-webhook", "1234")
        |> Router.call(@opts)

      assert conn.status == 202
      assert conn.resp_body == "Processing started"
    end

    test "returns 401 when authentication is missing" do
      conn =
        conn(:get, "/api/v1/github/AlefMach/gh_issues_contributors")
        |> Router.call(@opts)

      assert conn.status == 401
    end

    test "returns 404 for an invalid route" do
      conn =
        conn(:get, "/api/v1/github/nonexistent_route")

      assert conn.status == nil
    end
  end
end
