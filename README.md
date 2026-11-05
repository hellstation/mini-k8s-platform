## A mini project to practice Kubernetes and Helm.

![xdd](image.png)

* Manual deployment via Kubernetes YAML + Kustomize
* Deployment via Helm chart
* Ingress with a local domain
* Readiness and Liveness probes
* Horizontal Pod Autoscaler (HPA)
* Resource requests and limits
* Local development with Minikube

---

## Project Structure

```
mini-k8s-platform/
├── README.md
├── charts/
│   └── web-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── k8s/
│   ├── base/
│   │   ├── kustomization.yaml
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   └── overlays/
│       └── minikube/
│           ├── kustomization.yaml
│           ├── namespace.yaml
│           └── ingress.yaml
└── .gitignore
```

---

## Requirements

* MacOS / Linux
* Minikube
* kubectl
* Helm (for Helm deployment)
* Docker (for local builds/testing)

---

## Cluster setup

1. Start Minikube:

```bash
minikube start
```

2. Enable addons (Ingress for the local domain, metrics-server for HPA):

```bash
minikube addons enable ingress
minikube addons enable metrics-server
```

3. Add the local domain to `/etc/hosts`:

```
127.0.0.1 fofatafo.local
```

Pick **one** of the two deploy paths below. Do not install YAML and Helm at the same time in the same namespace.

---

## Manual Deployment via YAML (Kustomize)

```bash
kubectl apply -k k8s/overlays/minikube
```

This creates the `platform` namespace, base workloads, and the minikube Ingress.

Start a tunnel (required for Ingress on Docker Desktop / Mac):

```bash
sudo minikube tunnel
```

Check resources:

```bash
kubectl get pods,svc,ingress,hpa -n platform
```

Open the application:

```
http://fofatafo.local
```

Alternatively, skip Ingress and use NodePort:

```bash
minikube service fofatafo -n platform
```

---

## Deployment via Helm

From the project root:

```bash
helm install fofatafo ./charts/web-app -n platform --create-namespace
```

Check the release:

```bash
helm list -n platform
kubectl get pods,svc,ingress,hpa -n platform
```

If Ingress is enabled (default), start a tunnel:

```bash
sudo minikube tunnel
```

Open the app:

```
http://fofatafo.local
```

Upgrade after changing `values.yaml`:

```bash
helm upgrade fofatafo ./charts/web-app -n platform
```

Preview rendered manifests without installing:

```bash
helm template fofatafo ./charts/web-app -n platform
```

---

## Useful Commands

* View pod logs:

```bash
kubectl logs -n platform -l app=fofatafo
```

* Execute a shell inside a pod:

```bash
kubectl exec -n platform -it deploy/fofatafo -- /bin/sh
```

* Describe a pod and check readiness/liveness:

```bash
kubectl describe pod -n platform -l app=fofatafo
```

* Watch HPA:

```bash
kubectl get hpa -n platform -w
```

* Generate load so HPA can scale (metrics-server must be enabled):

```bash
kubectl run -n platform loadgen --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://fofatafo; done"
```

* Delete the Helm release:

```bash
helm uninstall fofatafo -n platform
```

* Delete the YAML/Kustomize install:

```bash
kubectl delete -k k8s/overlays/minikube
```

* Clean the namespace:

```bash
kubectl delete namespace platform
```

---

## Features

* Readiness and liveness probes check `/`
* HPA scales pods on CPU utilization (target 50%)
* Local domain `fofatafo.local` via Ingress (`ingressClassName: nginx`)
* NodePort on the YAML Service for `minikube service`
* Helm chart is parameterized via `values.yaml` (image, replicas, resources, probes, config, ingress, HPA)
* Kustomize overlay (`k8s/overlays/minikube`) adds namespace + Ingress on top of `k8s/base`

---

## Tips

* On Mac with the Docker driver, NodePort is not reachable directly — use `minikube service` or `minikube tunnel`
* Keep the terminal with `minikube tunnel` open while using Ingress
* HPA stays at `<unknown>` until metrics-server is running and has scraped CPU
* With HPA enabled, Helm omits `spec.replicas` so the autoscaler owns replica count
* Verify that the local domain resolves:

```bash
ping fofatafo.local
```

It should resolve to `127.0.0.1`.
