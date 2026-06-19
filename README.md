# Vagrant Kubernetes Cluster with Ansible, Cilium, Helm, and Custom Metrics

## What this project provides

- An Ansible controller VM
- A highly available Kubernetes topology using `kubeadm`
- HAProxy API load balancer
- 3 control-plane VMs
- 2 worker VMs
- containerd as the runtime
- Cilium as the CNI
- Hubble enabled for observability
- Helm-based sample app deployment
- Metrics Server
- Prometheus stack
- Prometheus Adapter
- HPA examples for CPU and custom metrics

## Topology

| VM | IP | Role | Notes |
|---|---:|---|---|
| ansible | 192.168.56.10 | Ansible controller | Runs playbooks |
| lb | 192.168.56.20 | API load balancer | HAProxy on 6443 |
| cp1 | 192.168.56.21 | Control plane | Cluster bootstrap |
| cp2 | 192.168.56.22 | Control plane | Additional master |
| cp3 | 192.168.56.23 | Control plane | Additional master |
| worker1 | 192.168.56.31 | Worker | Schedules workloads |
| worker2 | 192.168.56.32 | Worker | Schedules workloads |

## Design choices

### Kubernetes
This template uses a pinned Kubernetes minor release variable so it can be updated easily. Use a supported release that matches your lab and update `K8S_MINOR` if needed.

### CNI
Cilium is used because it offers modern networking, policy enforcement, and observability. Hubble is enabled in the install to provide flow visibility and troubleshooting.

### Container runtime
containerd is used because it is the standard Kubernetes-friendly CRI runtime.

### HA control plane
The control plane is fronted by HAProxy on `192.168.56.20:6443`. The cluster is bootstrapped on `cp1`, and `cp2`/`cp3` join as additional control-plane nodes.

## Setup

Bring up the VMs:

```bash
vagrant up
```

Enter the Ansible controller:

```bash
vagrant ssh ansible
```

Run the cluster bootstrap playbook:

```bash
cd /vagrant/ansible
ansible-playbook playbooks/bootstrap.yml
```

Run the application and monitoring playbook:

```bash
ansible-playbook playbooks/apps.yml
```

## Verify the cluster

SSH to `cp1` or use the Ansible VM with kubectl configured, then run:

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc -A
```

Expected:
- all control-plane and worker nodes are `Ready`
- `cilium` pods are running in `kube-system`
- `metrics-server` is running
- Prometheus/Grafana are running in `monitoring`

## Verify Cilium

```bash
kubectl -n kube-system get pods | grep cilium
kubectl -n kube-system get svc | grep hubble
```

Hubble UI is enabled by the Helm install. Use port-forward if you want to inspect flows.

## Deploy the sample application

The sample app is already deployed by `apps.yml`, but you can deploy it manually with:

```bash
kubectl apply -f k8s/sample-app/namespace.yaml
kubectl apply -f k8s/sample-app/configmap.yaml
kubectl apply -f k8s/sample-app/deployment.yaml
kubectl apply -f k8s/sample-app/service.yaml
```

Access it with NodePort:

```bash
curl http://192.168.56.31:30080
```

## Helm deployment

The Helm chart is in `helm/hello-world`. To install it manually:

```bash
helm upgrade --install hello-world ./helm/hello-world -n hello --create-namespace
```

## Custom metrics and HPA

The app exposes Prometheus-format metrics at `/metrics`, including:
- `http_requests_total`
- `http_request_latency_seconds_sum`

The monitoring flow is:

Application -> Prometheus -> Prometheus Adapter -> Custom Metrics API -> HPA

The custom HPA manifest uses the custom metric `http_requests_per_second`.

To test scaling:
1. Send traffic to the NodePort.
2. Watch metrics in Prometheus.
3. Check HPA status with:
   ```bash
   kubectl -n hello get hpa
   kubectl -n hello describe hpa hello-world-custom
   ```

## Security considerations

- Use RBAC with least privilege
- Keep secrets in Kubernetes Secrets or an external secrets manager
- Add NetworkPolicies where appropriate
- Prefer immutable images and scan them before deployment
- Store kubeconfig securely
- Avoid running workloads as root unless required

## Monitoring and logging

- Prometheus for metrics
- Grafana for dashboards
- Hubble for Cilium network visibility
- Loki or EFK can be added for logs

## Backup and disaster recovery

- Snapshot etcd regularly
- Back up any persistent volumes
- Keep the Ansible/Vagrant project in Git
- Treat the cluster as disposable; recreate from code
- For real environments, add Velero and off-cluster backups

## Production best practices

- 3 control-plane nodes minimum for quorum
- Separate load balancer from the control plane
- Pin versions intentionally and upgrade one minor at a time
- Automate node bootstrap
- Use namespaces, RBAC, and network policies
- Monitor capacity and set resource requests/limits
- Run workload and cluster health checks continuously

## Files included

- `Vagrantfile`
- `bootstrap/ansible-controller.sh`
- `ansible/` roles and playbooks
- `k8s/sample-app/` manifests
- `helm/hello-world/` chart
- `monitoring/` values files
- `docs/` notes



