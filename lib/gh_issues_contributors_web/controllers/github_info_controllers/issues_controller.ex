defmodule GhIssuesContributorsWeb.IssuesController do
  use OpenApiSpex.ControllerSpecs
  use GhIssuesContributorsWeb, :controller

  alias GhIssuesContributorsWeb.Swagger.Schemas.GhIssuesContributorsSchema
  alias GhIssuesContributorsWeb.Swagger.Response

  action_fallback(GhIssuesContributorsWeb.Fallback)

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
  def index(conn, %{"owner" => _owner, "repo" => _repo}) do
    # Implementação futura do serviço de busca de issues e contribuidores.
    # Esta função deve chamar um serviço que utiliza a API do GitHub.
    json(conn, %{message: "Not implemented yet"})
  end
end
