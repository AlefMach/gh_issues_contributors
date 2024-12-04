defmodule GhIssuesContributorsWeb.Swagger.Schemas.GhIssuesContributorsSchema do
  @moduledoc """
  Defines the schema for the response of GitHub issues and contributors, including the user and repository details.
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule GhIssuesContributorsResponse do
    @moduledoc """
    Schema for the response containing GitHub repository data with issues and contributors.
    """

    OpenApiSpex.schema(%{
      title: "GhIssuesContributorsResponse",
      description: "Response containing GitHub user, repository, issues, and contributors.",
      type: :object,
      properties: %{
        user: %Schema{
          type: :string,
          description: "Name of the user who made the request."
        },
        repository: %Schema{
          type: :string,
          description: "Name of the GitHub repository."
        },
        issues: %Schema{
          type: :array,
          description: "List of issues in the repository.",
          items: %Schema{
            type: :object,
            properties: %{
              title: %Schema{type: :string, description: "Title of the issue."},
              author: %Schema{type: :string, description: "Author of the issue."},
              labels: %Schema{
                type: :array,
                description: "Labels associated with the issue.",
                items: %Schema{type: :string, description: "Label name."}
              }
            },
            required: [:title, :author]
          }
        },
        contributors: %Schema{
          type: :array,
          description: "List of contributors to the repository.",
          items: %Schema{
            type: :object,
            properties: %{
              name: %Schema{type: :string, description: "Name of the contributor."},
              user: %Schema{type: :string, description: "GitHub username of the contributor."},
              qtd_commits: %Schema{type: :integer, description: "Number of commits made by the contributor."}
            },
            required: [:user, :qtd_commits]
          }
        }
      },
      required: [:user, :repository, :issues, :contributors],
      example: %{
        user: "john_doe",
        repository: "example_repo",
        issues: [
          %{
            title: "Fix authentication bug",
            author: "alice",
            labels: ["bug", "authentication"]
          },
          %{
            title: "Improve UI design",
            author: "bob",
            labels: ["enhancement", "UI"]
          }
        ],
        contributors: [
          %{
            name: "Alice Smith",
            user: "alice",
            qtd_commits: 25
          },
          %{
            name: "Bob Johnson",
            user: "bob",
            qtd_commits: 15
          }
        ]
      }
    })
  end
end
