## Tackling the initial TODOs

Now we have these TODOs, let's tackle them one by one.
I will be working together with the Gemini v3 pro model to tackle these tasks.
The changes and progress will be kept as throughly as possible via Github PRs.
As of this point, I've set up a github respository, and before I do the initial upload, I asked Gemini to double check there's no sensitive credentials that are accidentally left behind.

<details>
<summary>Transcript for security check</summary>

```
> Scan this repository to see if there are sensitive data that are not supposed to be pushed to a public place such as github

✦ I will scan the repository for sensitive data, starting by checking .gitignore and searching for common patterns of exposed secrets.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ✓  ReadFile .gitignore                                                                                                                                            │
│                                                                                                                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I will check config/database.yml and search for potential hardcoded secrets in the app and config directories.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ✓  ReadFile config/database.yml                                                                                                                                   │
│                                                                                                                                                                   │
│                                                                                                                                                                   │
│ ✓  SearchText '(password|secret|api_key|token)' within app                                                                                                        │
│                                                                                                                                                                   │
│ No matches found                                                                                                                                                  │
│                                                                                                                                                                   │
│ ✓  SearchText '(password|secret|api_key|token)' within config                                                                                                     │
│                                                                                                                                                                   │
│ Found 2 matches                                                                                                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I will verify if config/master.key exists and check config/environments/production.rb and Gemfile for any security concerns.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ✓  FindFiles 'config/master.key'                                                                                                                                  │
│                                                                                                                                                                   │
│ No files found                                                                                                                                                    │
│                                                                                                                                                                   │
│ ✓  ReadFile config/environments/production.rb                                                                                                                     │
│                                                                                                                                                                   │
│                                                                                                                                                                   │
│ ✓  ReadFile Gemfile                                                                                                                                               │
│                                                                                                                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I will check the content of tmp/local_secret.txt and db/seeds.rb for any potential secrets.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ x  ReadFile {"file_path":"tmp/local_secret.txt"}                                                                                                                  │
│                                                                                                                                                                   │
│ File path '/home/hiimdoublej/dev/tripla-interview/dynamic-pricing/tmp/local_secret.txt' is ignored by configured ignore patterns.                                 │
│                                                                                                                                                                   │
│ ✓  ReadFile db/seeds.rb                                                                                                                                           │
│                                                                                                                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I will verify that config/credentials.yml.enc is encrypted and search for any *.key files in the repository.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ✓  Shell file config/credentials.yml.enc [current working directory /home/hiimdoublej/dev/tripla-interview/dynamic-pricing]                                       │
│                                                                                                                                                                   │
│ config/credentials.yml.enc: ASCII text, with very long lines (456), with no line terminators                                                                      │
│                                                                                                                                                                   │
│ ✓  FindFiles '**/*.key'                                                                                                                                           │
│                                                                                                                                                                   │
│ No files found                                                                                                                                                    │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I will check config.ru and Rakefile for any potential issues.
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ✓  ReadFile config.ru                                                                                                                                             │
│                                                                                                                                                                   │
│                                                                                                                                                                   │
│ ✓  ReadFile Rakefile                                                                                                                                              │
│                                                                                                                                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
✦ I have completed the scan of the repository.

  Findings:
   - Checked `.gitignore`: It correctly excludes sensitive files such as config/master.key, .env files, logs (/log/*), temporary files (/tmp/*), and storage.
   - `config/master.key`: Verified it is not present in the file list.
   - `config/credentials.yml.enc`: Present and encrypted (safe to commit).
   - `config/database.yml`: Uses SQLite and environment variables. No hardcoded credentials found.
   - Codebase Search: Searched for keywords "password", "secret", "api_key", "token" in `app` and `config` directories. No hardcoded secrets were found (matches in
     `filter_parameter_logging.rb` are for log filtering, which is correct).
   - `db/seeds.rb`: Contains only default comments.
   - `tmp/local_secret.txt`: This file exists in your workspace but is correctly ignored by .gitignore (under /tmp/*).

  Conclusion:

> What was the conclusion ?

✦ The conclusion of the scan is that the repository is safe to push.

  Key findings:
   - No hardcoded secrets: Searches for keywords like password and api_key yielded no sensitive results.
   - Properly ignored files: Sensitive files like config/master.key and .env are not present, and the .gitignore correctly excludes them along with logs and
     temporary files.
   - Encrypted credentials: config/credentials.yml.enc is encrypted, which is the standard Rails practice for committing configuration safely.
   - Workspace file: tmp/local_secret.txt exists locally but is ignored by Git, preventing accidental exposure.
```
</details>

### TODOs

- [x] Setup docker compose with two services - `dynamic-pricing` and `rate-api`.

See PRs #1 and #2.

- [x] Integrate the API call of `rate-api` into `dynamic-pricing` with url/token configs from env var.

See PR #3.

- [x] Setup cache layer in the docker compose for `dynamic-pricing` to use.

See PR #9.

- [x] Implement DB model for the fetched rates.

See PR #10.

- [x] Implement rate fetching cronjob.

  - See PR #15

- [ ] Implement controller logic.
- [ ] Add tests for `dynamic-pricing`, mocking the `rate-api` service responses.

