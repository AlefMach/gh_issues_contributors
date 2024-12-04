# GhIssuesContributors

**GhIssuesContributors** is an Elixir project designed to fetch, process, and manage issues and contributors from GitHub repositories. The system integrates with webhooks and includes features for caching and error handling to provide a robust and extensible solution.

## Features

- Fetches issues and contributors from GitHub repositories.
- Filters issues and contributors based on specific timeframes (e.g., last 24 hours).
- Caches retrieved data for performance and reliability.
- Sends results or error messages to a configurable webhook via HTTP.
- Modular and testable with dependency mocks and robust unit tests.

## Installation

1. Clone the repository:

   ```bash
   git clonehttps://github.com/AlefMach/gh_issues_contributors.git
   cd gh_issues_contributors
   ```

2. Install dependencies:

   ```bash
   docker compose run --rm gh_issues_contributors mix deps.get
   ```

3. Run the tests to ensure everything is working:

   ```bash
   docker compose -f docker-compose.test.yml up
   ```

## Usage

### Key Functionality

1. **Processing Issues and Contributors**

   The `process_issues_and_contributors/4` function:
   - Fetches issues and contributors from a GitHub repository.
   - Caches the data.
   - Sends a webhook response with success or failure messages.

   Example:

   ```elixir
   GhIssuesContributors.Domain.ProcessRequest.process_issues_and_contributors(
     "owner_name", 
     "repo_name", 
     "webhook_id", 
     "cache_key"
   )
   ```

2. **Sending Webhook Responses**

   The webhook integration uses the `HTTPoison` library to send POST requests with JSON payloads.

   Example usage within the module:

   ```elixir
   Webhook.send_webhook_response("webhook_id", %{data: "example"}, "Operation successful")
   ```

3. **Fetching GitHub Data**

   GitHub data is retrieved using the `fetch_issues_and_contributors/2` function in the `Github.Service` module.

### Configuration

- **Timeouts**: The module uses configurable timeouts for HTTP requests (`@timeout`, `@recv_timeout`).
- **Mocks**: The system uses `Mox` for testing dependencies like GitHub and Webhook services.

## Testing

Run the unit tests to verify the application's functionality:

```bash
mix test
```

Key test modules include:
- `GhIssuesContributors.Domain.ProcessRequestTest`: Validates the logic for processing issues and contributors.
- Mocks for GitHub and Webhook services.
- Validate controllers

Example test scenario:

- Fetch issues and contributors successfully:
  - Caches the data.
  - Sends a success message via webhook.
- Handles failure gracefully:
  - Logs the error.
  - Sends an error message via webhook.

## Documentation

To generate the project's documentation, run:

```bash
mix docs
```

Access the generated documentation in the `doc` directory.

## License

This project is licensed under the [MIT License](LICENSE).