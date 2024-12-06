
# GhIssuesContributors

**GhIssuesContributors** is an Elixir project designed to fetch, process, and manage issues and contributors from GitHub repositories. The system integrates with webhooks and includes features for caching and error handling, providing a robust and extensible solution.

## Features

- Fetches issues and contributors from GitHub repositories.
- Caches retrieved data for performance and reliability.
- Sends results or error messages to a configurable webhook via HTTPS after a time configured .env file.
- Modular, testable, and supports dependency mocks for robust unit testing.

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/AlefMach/gh_issues_contributors.git
cd gh_issues_contributors
```

### Step 2: Install Dependencies

```bash
docker compose run --rm gh_issues_contributors mix deps.get
```

### Step 3: Run the Tests to Ensure Everything is Working

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

   The webhook integration uses the `HTTPoison` library to send POST requests with JSON payloads to a webhook URL.

   Example usage:

   ```elixir
   GhIssuesContributors.Adapters.WebhookSite.Service.send_webhook_response("webhook_id", %{data: "example"}, "Operation successful")
   ```

3. **Fetching GitHub Data**

   GitHub data is retrieved using the `fetch_issues_and_contributors/2` function in the `GhIssuesContributors.Adapters.Github.Service` module.

### Configuration

- **Timeouts**: The module uses configurable timeouts for HTTP requests:
  - `@timeout`: Request timeout (default: 30,000 ms).
  - `@recv_timeout`: Response timeout (default: 30,000 ms).

- **Mocks**: The system uses `Mox` for testing dependencies like GitHub and Webhook services.

### Headers

To communicate with the API, the following mandatory headers must be included in your requests:

- **`x-gh-auth`**: Generic authentication header. Can contain any value for testing or API integration purposes.
- **`x-id-webhook`**: Unique identifier for the webhook site (e.g., `https://webhook.site/dee6f722-4d56-44fa-b6af-7c29e9ed6206`, you will use the `dee6f722-4d56-44fa-b6af-7c29e9ed6206` ID).

Example of configuring headers in a request:

```elixir
headers = [
  {"x-gh-auth", "any_value_for_authentication"},
  {"x-id-webhook", "webhook_id"}
]
```

## Testing

Run the unit tests to verify the application's functionality:

```bash
mix test
```

Key test modules include:

- `GhIssuesContributors.Domain.ProcessRequestTest`: Validates the logic for processing issues and contributors.
- Mocks for GitHub and Webhook services.
- Controller tests.

Example test scenarios:

- **Successful Fetch**:
  - Fetches issues and contributors.
  - Caches the data.
  - Sends a success message via webhook.

- **Failure Handling**:
  - Logs errors when fetching data fails.
  - Sends an error message via webhook.

## Documentation

To generate the project's documentation, run:

```bash
mix docs
```

Access the generated documentation in the `doc` directory.

## License

This project is licensed under the [MIT License](LICENSE).