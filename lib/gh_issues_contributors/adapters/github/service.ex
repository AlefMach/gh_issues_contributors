defmodule GhIssuesContributors.Adapters.Github.Service do
  alias HTTPoison
  require Logger

  @github_api_url "https://api.github.com/repos"
  @github_token System.get_env("GITHUB_TOKEN")

  @doc """
  Busca as issues e os contribuidores de um repositório no GitHub, filtrando as issues
  criadas nas últimas 24 horas e os contribuidores que realizaram commits nesse intervalo.

  ## Parâmetros:
    - owner: Nome do proprietário do repositório.
    - repo: Nome do repositório.

  ## Retorna:
    - {:ok, %{issues: issues, contributors: contributors}} em caso de sucesso, onde issues
      é uma lista de issues e contributors é uma lista de contribuintes.
    - {:error, reason} em caso de falha.
  """
  def fetch_issues_and_contributors(owner, repo) do
    issues_url = "#{@github_api_url}/#{owner}/#{repo}/issues"
    contributors_url = "#{@github_api_url}/#{owner}/#{repo}/contributors"

    headers = [
      {"User-Agent", "Elixir"},
      {"Authorization", "token #{@github_token}"}
    ]

    one_day_ago = DateTime.utc_now() |> DateTime.add(-24 * 3600, :second) |> DateTime.to_iso8601()

    issues_url_with_filter = "#{issues_url}?since=#{one_day_ago}"

    issues_response = HTTPoison.get(issues_url_with_filter, headers)
    contributors_response = HTTPoison.get(contributors_url, headers)

    case {issues_response, contributors_response} do
      {{:ok, %HTTPoison.Response{status_code: 200, body: issues_body}},
       {:ok, %HTTPoison.Response{status_code: 200, body: contributors_body}}} ->
        issues = parse_issues(issues_body)
        contributors = parse_contributors_by_activity(contributors_body, owner, repo, one_day_ago, headers)

        Logger.info("[Adapters.Github.Service] Issues and contributors fetched successfully for repo #{repo}.")

        {:ok, %{issues: issues, contributors: contributors}}

      {{:ok, %HTTPoison.Response{status_code: status, body: issues_body}}, _}
      when status != 200 ->
        Logger.error("[Adapters.Github.Service] Error fetching issues for repo #{repo}: #{issues_body}")
        {:error, "Failed to fetch issues. GitHub responded with status #{status}."}

      {_, {:ok, %HTTPoison.Response{status_code: status, body: contributors_body}}}
      when status != 200 ->
        Logger.error("[Adapters.Github.Service] Error fetching contributors for repo #{repo}: #{contributors_body}")
        {:error, "Failed to fetch contributors. GitHub responded with status #{status}."}

      _ ->
        Logger.error("[Adapters.Github.Service] Error fetching issues and/or contributors for repo #{repo}.")
        {:error, "Failed to fetch issues and/or contributors."}
    end
  end

  defp parse_contributors_by_activity(contributors_body, owner, repo, one_day_ago, headers) do
    contributors = Jason.decode!(contributors_body)

    contributors
    |> Enum.filter(fn contributor ->
      commits_url = "#{@github_api_url}/#{owner}/#{repo}/commits?author=#{contributor["login"]}&since=#{one_day_ago}"
      commits_response = HTTPoison.get(commits_url, headers)

      case commits_response do
        {:ok, %HTTPoison.Response{status_code: 200, body: commits_body}} ->
          commits = Jason.decode!(commits_body)

          Enum.any?(commits, fn commit -> commit["commit"]["author"]["date"] >= one_day_ago end)

        _ -> false
      end
    end)
    |> Enum.map(fn contributor ->
      %{
        name: contributor["login"],
        user: contributor["login"],
        qtd_commits: contributor["contributions"]
      }
    end)
  rescue
    e ->
      Logger.error("[Adapters.Github.Service] Failed to parse contributors: #{inspect(e)}")
      {:error, "Failed to parse contributors"}
  end

  defp parse_issues(body) do
    body
    |> Jason.decode!()
    |> Enum.map(fn issue ->
      %{
        title: issue["title"],
        author: issue["user"]["login"],
        labels: Enum.map(issue["labels"], fn label -> label["name"] end)
      }
    end)
  rescue
    e ->
      Logger.error("[Adapters.Github.Service] Failed to parse issues: #{inspect(e)}")
      {:error, "Failed to parse issues"}
  end
end