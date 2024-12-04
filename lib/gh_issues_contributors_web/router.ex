defmodule GhIssuesContributorsWeb.Router do
  use GhIssuesContributorsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
  end

  pipeline :api_swagger do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: GhIssuesContributorsWeb.Swagger.ApiSpec)
  end

  scope "/api/v1", GhIssuesContributorsWeb do
    pipe_through [:api, GhIssuesContributorsWeb.Plugs.AuthHeaderCheck, GhIssuesContributorsWeb.Plugs.Cache]

    get("/github/:owner/:repo", IssuesController, :index)
  end

  scope "/openapi" do
    pipe_through(:api_swagger)

    get("/", OpenApiSpex.Plug.RenderSpec, [])
  end

  scope "/" do
    pipe_through(:browser)

    get("/health-check", GhIssuesContributorsWeb.HealthCheckController, :check)
    get("/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/openapi")
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gh_issues_contributors, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: GhIssuesContributorsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
