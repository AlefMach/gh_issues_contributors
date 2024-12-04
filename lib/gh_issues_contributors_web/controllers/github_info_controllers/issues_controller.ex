defmodule GhIssuesContributorsWeb.IssuesController do
  use OpenApiSpex.ControllerSpecs
  use GhIssuesContributorsWeb, :controller

  alias GhIssuesContributorsWeb.Swagger.Schemas.GhIssuesContributorsSchema
  alias GhIssuesContributorsWeb.Swagger.Response
  alias GhIssuesContributorsWeb.Utils

  alias GhIssuesContributors.Adapters.Github.Service, as: Github

  require Logger

  @doc """
  Retrieves issues and contributors from a given GitHub repository.

  ## Parameters
  - `owner` (string, required): The owner of the repository.
  - `repo` (string, required): The repository name.

  ## Responses
  - `200`: A JSON object containing issues and contributors.
  - `401`: Unauthorized request if authentication fails.
  """
  operation(:index,
    parameters: [
      %OpenApiSpex.Parameter{
        name: :owner,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{
          type: :string,
          description: "Owner of the GitHub repository (user or organization).",
          example: "AlefMach"
        }
      },
      %OpenApiSpex.Parameter{
        name: :repo,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{
          type: :string,
          description: "Repository name.",
          example: "gh_issues_contributors"
        }
      }
    ],
    responses:
      [
        ok: {"Successful response", "application/json", GhIssuesContributorsSchema.GhIssuesContributorsResponse}
      ] ++ Response.errors([:unauthorized])
  )

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"owner" => owner, "repo" => repo}) do
    case Github.fetch_issues_and_contributors(owner, repo) do
      {:ok, %{issues: issues, contributors: contributors}} ->
        data = %{
          user: owner,
          repository: repo,
          issues: issues,
          contributors: contributors
        }
        RememberMe.guard(Utils.cache_key(conn), data, min: 10)
        json(conn, data)

      {:error, reason} ->
        Logger.error("Failed to fetch issues and contributors: #{reason}")
        conn
        |> send_resp(404, "Failed to fetch issues and contributors")
        |> halt()
    end
  end
end
