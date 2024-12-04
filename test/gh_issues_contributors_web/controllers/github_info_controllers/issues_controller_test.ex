defmodule GhIssuesContributorsWeb.IssuesControllerTest do
  use GhIssuesContributorsWeb.ConnCase, async: false

  import GhIssuesContributorsWeb.TestSupport

  setup %{conn: conn} do
    final_conn =
      conn
      |> login()

    %{conn: final_conn}
  end

  describe "index/2" do
    test "returns issues and contributors with valid repository", %{conn: conn} do
      response = get(conn, "/github/owner_name/repo_name")

      expected_response = %{
        "user" => "owner_name",
        "repository" => "repo_name",
        "issues" => [
          %{
            "title" => "Issue 1",
            "author" => "author_name",
            "labels" => ["bug", "help wanted"]
          },
          %{
            "title" => "Issue 2",
            "author" => "author_name",
            "labels" => ["enhancement"]
          }
        ],
        "contributors" => [
          %{
            "name" => "contributor_name",
            "user" => "contributor_user",
            "qtd_commits" => 5
          },
          %{
            "name" => "another_contributor_name",
            "user" => "another_contributor_user",
            "qtd_commits" => 2
          }
        ]
      }

      assert json_response(response, 200)

      assert response.resp_body == Jason.encode!(expected_response)
    end

    test "returns empty data for non-existent repository", %{conn: conn} do
      response = get(conn, "/github/invalid_owner/invalid_repo")

      expected_response = %{
        "user" => "invalid_owner",
        "repository" => "invalid_repo",
        "issues" => [],
        "contributors" => []
      }

      assert json_response(response, 200)

      assert response.resp_body == Jason.encode!(expected_response)
    end

    test "returns error for invalid owner/repository format", %{conn: conn} do
      response = get(conn, "/github/owner_name/invalid_repo_name")

      assert json_response(response, 400)
      assert response.resp_body == "{\"error\":{\"details\":\"Invalid repository format\"}}"
    end

    test "returns 404 for a non-existent owner", %{conn: conn} do
      response = get(conn, "/github/non_existent_owner/repo_name")

      assert json_response(response, 404)
      assert response.resp_body == "{\"error\":{\"details\":\"Repository or owner not found\"}}"
    end
  end
end
