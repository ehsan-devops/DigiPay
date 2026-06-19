# HPA with Custom Metrics

Kubernetes HPA can scale on CPU and memory through Metrics Server, and on application-specific metrics through the Custom Metrics API.

## Flow

1. The app exposes metrics, for example `http_requests_total`.
2. Prometheus scrapes those metrics.
3. Prometheus Adapter exposes the metric through `custom.metrics.k8s.io`.
4. HPA reads that metric and scales the Deployment.

## Example metric

The sample app exposes:

- `http_requests_total`
- `http_request_latency_seconds_sum`

A Prometheus Adapter rule maps `http_requests_total` to `http_requests_per_second`.

## Example HPA target

The sample manifest scales based on:

- metric: `http_requests_per_second`
- target average value: `5`

## Notes

- Keep the metric stable and well-defined.
- Add stabilization windows if your workload fluctuates.
- Use CPU HPA as a fallback for simple autoscaling.
