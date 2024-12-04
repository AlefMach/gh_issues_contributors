defmodule GhIssuesContributorsWeb.IssuesController do
  use OpenApiSpex.ControllerSpecs
  use GhIssuesContributorsWeb, :controller

  alias GhIssuesContributorsWeb.Swagger.Schemas.GhIssuesContributorsSchema
  alias GhIssuesContributorsWeb.Swagger.Response
  alias GhIssuesContributors.Domain.ProcessRequest
  alias GhIssuesContributorsWeb.Utils

  require Logger

  @doc """
  Retrieves issues and contributors from a given GitHub repository.

  ## Parameters
  - `owner` (string, required): The owner of the repository.
  - `repo` (string, required): The repository name.

  ## Responses
  - `202`: Accepted response indicating the process is running.
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
        accepted: {"Processing started", "application/json", GhIssuesContributorsSchema.GhIssuesContributorsResponse},
        ok: {"Successful response", "application/json", GhIssuesContributorsSchema.GhIssuesContributorsResponse}
      ] ++ Response.errors([:unauthorized])
  )

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"owner" => owner, "repo" => repo}) do
    id_webhook = get_req_header(conn, "x-id-webhook")
    key = Utils.cache_key(conn)

    Task.start(fn ->
      ProcessRequest.process_issues_and_contributors(owner, repo, id_webhook, key)
    end)

    conn
    |> send_resp(202, "Processing started")
    |> halt()
  end
end
