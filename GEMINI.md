# Dynamic Pricing API

This repository contains a Ruby on Rails API application for a dynamic pricing service. It is designed to calculate room rates based on various parameters like season, hotel, and room type.

## Project Structure

- **Framework**: Ruby on Rails 7.1.5
- **Ruby Version**: 3.2.6
- **Database**: SQLite3 (Standard Rails default, though currently not heavily used for the logic shown)
- **Server**: Puma
- **External Services**:
    - **pricing-api**: A Flask-based API for external rate lookups, running on port 8080.

## Setup and Installation

1.  **Install Dependencies**:
    ```bash
    bundle install
    ```

2.  **Database Setup** (Standard Rails procedure):
    ```bash
    bin/rails db:migrate
    ```

## Running the Application

To start the server:

```bash
bin/rails server
```

The application will be available at `http://localhost:3000`.

### Using Docker Compose

To start the application using Docker Compose:

```bash
docker compose up --build
```

The application will be available at `http://localhost:3000`.

## Testing

The project uses the standard Rails testing framework (`Minitest`).

To run the full test suite:

```bash
bin/rails test
```

To run specifically the pricing controller tests:

```bash
bin/rails test test/controllers/pricing_controller_test.rb
```

## Maintenance

**Note to Agent**:
- Whenever a new Gemini CLI session is started, switch to a new worktree by `git worktree add ./.gemini-session-<GEMINI_SESSION_ID> -b gemini-session-<GEMINI_SESSION_ID>` to avoid conflicts with other gemini CLI sessions.
- When resolving conflicts, make sure to read the commits from both sides before coming up with resolution ideas.
- After a code change, make a commit with sensible commit messages. The commit title should start with "Gemini: ".
- Whenever you need to run anything related to the applications (especially tests), run them within the docker compose containers.
- After every task, come back to `GEMINI.md` and ensure it still accurately reflects the project's state, setup instructions, and API documentation.
- After every application code change, run the tests and fix any problems that comes with it.
