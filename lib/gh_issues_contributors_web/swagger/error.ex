defmodule GhIssuesContributorsWeb.Swagger.Error do
  @moduledoc """
  Contains definitions for various error schemas used in API responses.
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  # Schema for Unauthorized error
  defmodule Unauthorized do
    @moduledoc "Schema for 401 Unauthorized error responses."

    OpenApiSpex.schema(%{
      title: "Unauthorized",
      description: "Unauthorized access. Invalid or missing API key or JWT user token.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{type: :string, description: "Error details message"}
          }
        }
      },
      example: %{
        "error" => %{
          "details" => "Invalid API key"
        }
      }
    })
  end

  # Schema for Forbidden error
  defmodule Forbidden do
    @moduledoc "Schema for 403 Forbidden error responses."

    OpenApiSpex.schema(%{
      title: "Forbidden",
      description: "Access denied. You don't have permission to access this resource.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{type: :string, description: "Error details message"}
          }
        }
      },
      example: %{
        "error" => %{
          "details" => "You do not have the required permissions"
        }
      }
    })
  end

  # Schema for Generic Error
  defmodule GenericError do
    @moduledoc "Schema for generic error responses."

    OpenApiSpex.schema(%{
      title: "Error",
      description: "A generic error message structure.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{type: :string, description: "Detailed error message"}
          }
        }
      },
      example: %{
        "error" => %{
          "details" => "The requested item does not exist"
        }
      }
    })
  end

  # Schema for Conflict Error
  defmodule ConflictError do
    @moduledoc "Schema for 409 Conflict error responses."

    OpenApiSpex.schema(%{
      title: "ConflictError",
      description: "Error message for resource conflicts during creation.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{type: :string, description: "Conflict error details"},
            resourceId: %Schema{type: :integer, description: "ID of the conflicting resource"}
          }
        }
      },
      example: %{
        "error" => %{
          "details" => "The item already exists",
          "resourceId" => 1
        }
      }
    })
  end

  # Schema for Unprocessable Entity Error
  defmodule UnprocessableEntityError do
    @moduledoc "Schema for 422 Unprocessable Entity error responses."

    OpenApiSpex.schema(%{
      title: "UnprocessableEntityError",
      description: "Validation error message.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{
              type: :object,
              description: "Details about the validation error",
              additionalProperties: %Schema{type: :string}
            }
          }
        }
      },
      example: %{
        "error" => %{
          "details" => %{"file" => "Invalid file type"}
        }
      }
    })
  end

  # Schema for Bad Request Error
  defmodule BadRequest do
    @moduledoc "Schema for 400 Bad Request error responses."

    OpenApiSpex.schema(%{
      title: "BadRequest",
      description: "Error message for malformed requests.",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            details: %Schema{
              type: :object,
              description: "Details about the missing or invalid parameters",
              additionalProperties: %Schema{type: :string}
            }
          }
        }
      },
      example: %{
        "error" => %{
          "details" => %{"step" => "Step is required"}
        }
      }
    })
  end
end
