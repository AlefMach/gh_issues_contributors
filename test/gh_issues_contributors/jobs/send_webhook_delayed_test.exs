defmodule GhIssuesContributors.Jobs.SendWebhookDelayedTest do
  use ExUnit.Case, async: false

  alias GhIssuesContributors.Jobs.SendWebhookDelayed
  alias Oban.Job
  alias GhIssuesContributors.Repo

  import Ecto.Query, only: [from: 2]

  use Oban.Testing, repo: GhIssuesContributors.Repo

  setup do
    on_exit(fn ->
      Ecto.Adapters.SQL.query!(Repo, "TRUNCATE oban_jobs RESTART IDENTITY CASCADE", [])
    end)

    :ok
  end

  describe "scheduled jobs" do
    test "schedules job with correct delay" do
      delay = 3600  # 1 hour in seconds

      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "delayed message"}
        |> SendWebhookDelayed.new(schedule_in: delay)
        |> Oban.insert()

        assert_enqueued(
          worker: SendWebhookDelayed,
          args: %{"id_webhook" => "1234", "data" => "any data", "message" => "delayed message"}
        )

        job =
          Repo.one!(
            from j in Job,
            where: j.queue == "webhook"
          )

        expected_time = DateTime.add(DateTime.utc_now(), delay, :second) |> DateTime.truncate(:second)
        assert abs(DateTime.diff(job.scheduled_at, expected_time)) <= 10
      end)
    end
  end

  describe "perform/1" do
    test "sends webhook successfully" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "successful"}
        |> SendWebhookDelayed.new()
        |> Oban.insert()

        assert_enqueued(
          worker: SendWebhookDelayed,
          args: %{"id_webhook" => "1234", "data" => "any data", "message" => "successful"}
        )
      end)
    end

    test "fails to send webhook and retries" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "retry on failure"}
        |> SendWebhookDelayed.new()
        |> Oban.insert()

        assert_enqueued(
          worker: SendWebhookDelayed,
          args: %{"id_webhook" => "1234", "data" => "any data", "message" => "retry on failure"}
        )
      end)
    end

    test "does not retry if max_attempts is reached" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "no retry after max attempts"}
        |> SendWebhookDelayed.new()
        |> Oban.insert()

        refute_receive {:oban, {:retry, _job, _reason}}
      end)
    end
  end
end
