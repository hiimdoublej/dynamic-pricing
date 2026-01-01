## Tackling the initial TODOs

Now we have these TODOs, let's tackle them one by one.
I will be working together with the Gemini v3 pro model to tackle these tasks.
The changes and progress will be kept as throughly as possible via Github PRs.

- [ ] Setup docker compose with two services - `dynamic-pricing` and `rate-api`.
- [ ] Integrate the API call of `rate-api` into `dynamic-pricing` with url/token configs from env var.
- [ ] Setup cache layer in the docker compose for `dynamic-pricing` to use.
- [ ] Implement DB model for the fetched rates.
- [ ] Implement rate fetching cronjob.
- [ ] Implement controller logic.
- [ ] Add tests for `dynamic-pricing`, mocking the `rate-api` service responses.

