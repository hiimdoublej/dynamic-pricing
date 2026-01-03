## Figuring out the TODOs

At this point I roughly know how this application works. I reviewed the original README.md to figure out the TODOs, namely changes needed to the current repository.

### Satisfying the core requirements: Integration

As I go through the core requirements, it's clear that there's a seperate service (`rate-api`) that I have to connect our current application to, and it's already in the format of a docker image.
Upon reading this, my immediate thought is to put together a `docker compose` setup that includes both the current application (`dynamic-pricing`) and the `rate-api` containers.

On the `dynamic-pricing` side of things, we need to integrate the logic that will fetch the rate from the `rate-api` service. The code should implement it just like any integrating any other 3rd party API, with sensible error handling and environment variables.

### Satisfying the core requirements: Rate Validity

Any rate fetched from the `rate-api` is only valid for 5 minutes. The `dynamic-pricing` api must not serve any rate that is older than this 5-minute window.

The simple approach to satisfy this requirement is to just add a cache layer with ttl of 5 minutes, and have the server fetch on any cache miss. But doing it this way might cause the server latency to suffer when the 3rd party service isn't working properly. Also, the 3rd party service has a rate limit of 1000 requests per day, we're also risking the rate limit being exhausted at the end of the day and we have no prices to give to anyone. We can only tolerate 1000 cache misses, which doesn't sound too good.

Another idea is that we setup a cronjob to fetch the rates periodically for every combination, save it to DB with a fetch time stamp, and also introduce a cache layer on top of it. On cache miss, fetch DB for the latest price for the given combination. This eliminates the risk of 3rd party API instability, allowing a 5 minute window of 3rd party API failures, and if we setup the interval correctly, we can fit the rate limit. The drawback would be the amount of requests that we have to send, and it uses significantly more storage than the first solution. But for the sake of keeping our business alive for as long as possible, this seems like a ok tradeoff. If the product doesn't work, it won't matter how efficient it is.

### Satisfying the core requirements: Usage Limits

Since we're going with a periodically fetch approach, let's calculate a interval that fits within the ratelimit. Assuming all combinations can be fetched within a single request, the tighest interval we can do without hitting the ratelimit on the other side is 86400 / 1000 = 86.4 seconds. We'll set it to 90 seconds for now since it's a close nice number that fits into the rate limit.

This setup should be able to handle at least 10k request per day for the `dynamic-pricing` service since the number of outgoing requests is a constant.

## Final TODOs

So far we've been through the core requirements, it is now time to write them down as a checklist so that we can complete later.

- [ ] Setup docker compose with two services - `dynamic-pricing` and `rate-api`.
- [ ] Integrate the API call of `rate-api` into `dynamic-pricing` with url/token configs from env var.
- [ ] Setup cache layer in the docker compose for `dynamic-pricing` to use.
- [x] Implement DB model for the fetched rates.
- [ ] Implement rate fetching cronjob.
- [ ] Implement controller logic.
- [ ] Add tests for `dynamic-pricing`, mocking the `rate-api` service responses.
