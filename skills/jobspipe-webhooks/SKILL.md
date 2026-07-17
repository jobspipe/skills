---
name: jobspipe-webhooks
description: Receive and verify JobsPipe job-event webhooks (job.created, job.closed) with HMAC-SHA256 signature checks and replay protection. Use when building a service that reacts to new or closed job postings in real time instead of polling.
---

# JobsPipe webhooks

JobsPipe POSTs job events to your endpoint: `job.created` when a new posting
matches a saved subscription, and `job.closed` when a tracked job transitions
from open to closed (paid plans). Webhook URLs and signing secrets are managed
from the dashboard at https://jobspipe.dev/dashboard.

## Payload

`job.closed` bodies are `{ event, id, timestamp, data }` where `data` carries
the job fields plus `closed_reason` and `closed_at`. `job.created` bodies are
the normalized job record itself.

## Verify every delivery

Each request carries two headers:

- `X-JobsPipe-Timestamp` — Unix seconds of the delivery.
- `X-JobsPipe-Signature` — hex-encoded HMAC-SHA256 of
  `{X-JobsPipe-Timestamp}.{raw request body}` computed with your signing
  secret.

Verification steps:

1. Reject if `X-JobsPipe-Timestamp` is older than 5 minutes (replay guard).
2. Compute `HMAC_SHA256(secret, timestamp + "." + rawBody)` over the raw,
   unparsed body bytes.
3. Compare with `X-JobsPipe-Signature` in constant time; reject on mismatch.

Node example:

```js
import { createHmac, timingSafeEqual } from "node:crypto";

function verify(rawBody, headers, secret) {
  const ts = headers["x-jobspipe-timestamp"];
  if (Math.abs(Date.now() / 1000 - Number(ts)) > 300) return false;
  const expected = createHmac("sha256", secret)
    .update(`${ts}.${rawBody}`)
    .digest("hex");
  const given = headers["x-jobspipe-signature"] ?? "";
  return (
    expected.length === given.length &&
    timingSafeEqual(Buffer.from(expected), Buffer.from(given))
  );
}
```

## Delivery contract

Respond `2xx` within 5 seconds or JobsPipe retries with exponential backoff.
Do heavy processing async: acknowledge first, then enqueue.

The webhook contract is also machine-readable in the `webhooks` section of the
OpenAPI spec at https://jobspipe.dev/openapi.json.
