defmodule GhIssuesContributors.Adapters.Github.Service do
  alias HTTPoison
  require Logger

  @github_api_url "https://api.github.com/repos"
  @github_token System.get_env("GITHUB_TOKEN")

  @behaviour GhIssuesContributors.Adapters.Github.ServiceBehaviour

  @doc """
  Fetches the issues and contributors of a GitHub repository.

  ## Parameters:
    - owner: The repository owner's name.
    - repo: The repository's name.

  ## Returns:
    - {:ok, %{issues: issues, contributors: contributors}} on success, where `issues` is
      a list of issues and `contributors` is a list of contributors.
    - {:error, reason} on failure.
  """
  @spec fetch_issues_and_contributors(String.t(), String.t()) ::
          {:ok, %{issues: list(), contributors: list()}} | {:error, String.t()}
  def fetch_issues_and_contributors(owner, repo) do
    issues_url = build_url(owner, repo, "issues")
    contributors_url = build_url(owner, repo, "contributors")

    headers = build_headers()

    with {:ok, issues_body} <- fetch_data(issues_url, headers),
         {:ok, contributors_body} <- fetch_data(contributors_url, headers) do
      issues = parse_issues(issues_body)
      contributors = parse_contributors(contributors_body, owner, repo, headers)

      Logger.info("[Adapters.Github.Service] Issues and contributors fetched successfully for repo #{repo}.")
      {:ok, %{issues: issues, contributors: contributors}}
    else
      {:error, reason} ->
        Logger.error("[Adapters.Github.Service] Error fetching data for repo #{repo}: #{reason}")
        {:error, reason}
    end
  end

  defp build_url(owner, repo, resource) do
    "#{@github_api_url}/#{owner}/#{repo}/#{resource}"
  end

  defp build_headers do
    [
      {"User-Agent", "Elixir"},
      {"Authorization", "token #{@github_token}"}
    ]
  end

  defp fetch_data(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "GitHub responded with status #{status}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch data: #{reason}"}
    end
  end

  defp parse_issues(body) do
    body
    |> Jason.decode!()
    |> Enum.map(&map_issue/1)
  rescue
    e ->
      log_parsing_error("issues", e)
      {:error, "Failed to parse issues"}
  end

  defp parse_contributors(body, owner, repo, headers) do
    body
    |> Jason.decode!()
    |> Enum.map(&map_contributor(&1, owner, repo, headers))
    |> Enum.filter(&(&1 != nil))
  rescue
    e ->
      log_parsing_error("contributors", e)
      {:error, "Failed to parse contributors"}
  end

  defp map_issue(issue) do
    %{
      title: issue["title"],
      author: issue["user"]["login"],
      labels: Enum.map(issue["labels"], & &1["name"])
    }
  end

  defp map_contributor(contributor, owner, repo, headers) do
    commits_url = build_url(owner, repo, "commits?author=#{contributor["login"]}")

    case fetch_data(commits_url, headers) do
      {:ok, _commits_body} ->
        %{
          name: contributor["login"],
          user: contributor["login"],
          qtd_commits: contributor["contributions"]
        }

      _ ->
        nil
    end
  end

  defp log_parsing_error(resource, error) do
    Logger.error("[Adapters.Github.Service] Failed to parse #{resource}: #{inspect(error)}")
  end
end
