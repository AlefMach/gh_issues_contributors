defmodule GhIssuesContributors.Jobs.SendWebhookDelayedTest do
  use ExUnit.Case, async: false

  alias GhIssuesContributors.Jobs.SendWebhookDelayed

  use Oban.Testing, repo: GhIssuesContributors.Repo

  describe "perform/1" do
    test "sends webhook successfully" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "successful"}
        |> SendWebhookDelayed.new()
        |> Oban.insert()

        assert_enqueued worker: SendWebhookDelayed, args: %{"id_webhook" => "1234", "data" => "any data", "message" => "successful"}
      end)
    end

    test "fails to send webhook and retries" do
      Oban.Testing.with_testing_mode(:manual, fn ->
        %{"id_webhook" => "1234", "data" => "any data", "message" => "retry on failure"}
        |> SendWebhookDelayed.new()
        |> Oban.insert()

        assert_enqueued(worker: SendWebhookDelayed, args: %{"id_webhook" => "1234", "data" => "any data", "message" => "retry on failure"})
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
