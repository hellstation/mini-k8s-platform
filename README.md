## A mini project to practice Kubernetes and Helm.

![xdd](image.png)

* Manual deployment via Kubernetes YAML
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
│ └── templates/ 
│ └── web-app/
├── k8s/
│ ├── base/
│ │ ├── deployment.yaml
│ │ ├── service.yaml
│ │ ├── configmap.yaml
│ │ └── hpa.yaml
│ └── overlays/
│ └── minikube/
│ └── ingress.yaml
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

## Manual Deployment via YAML

1. Start Minikube:

```bash
minikube start
```

2. Check cluster status:

```bash
kubectl get nodes
```

3. (Optional) Create a namespace:

```bash
kubectl create namespace platform
```

4. Apply manifests:

```bash
kubectl apply -f k8s/base/ -n platform
kubectl apply -f k8s/overlays/minikube/ -n platform
```

5. Enable Ingress:

```bash
minikube addons enable ingress
```

6. Add local domain to `/etc/hosts`:

```
127.0.0.1 fofatafo.local
```

7. Start Minikube tunnel (required for Ingress on Mac):

```bash
sudo minikube tunnel
```

8. Check pods, services, and ingress:

```bash
kubectl get pods -n platform
kubectl get svc -n platform
kubectl get ingress -n platform
```

9. Open the application in browser:

```
http://fofatafo.local
```

> Alternatively, if you want to use NodePort without Ingress:

```bash
minikube service fofatafo -n platform
```

---

## Deployment via Helm

1. Go to project root:

```bash
cd charts
```

2. Install the Helm chart:

```bash
helm install fofatafo ./web-app
```

3. Check the deployment:

```bash
helm list
kubectl get pods
kubectl get svc
kubectl get ingress
```

4. If Ingress is enabled, start tunnel:

```bash
sudo minikube tunnel
```

5. Open the app:

```
http://fofatafo.local
```

6. To upgrade after changes:

```bash
helm upgrade fofatafo ./web-app
```

---

## Useful Commands

* View pod logs:

```bash
kubectl logs <pod-name>
```

* Execute a shell inside pod:

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

* Describe pod and check readiness/liveness:

```bash
kubectl describe pod <pod-name>
```

* Delete Helm release:

```bash
helm uninstall fofatafo
```

* Clean all resources:

```bash
kubectl delete namespace platform
```

---

## Features

* Readiness and Liveness probes check `/` path
* HPA automatically scales pods based on CPU
* Local domain `fofatafo.local` for Ingress
* NodePort available for quick testing via `minikube service`
* Helm chart is fully parameterized via `values.yaml` (image, replicas, resources, probes)

---

## Tips

* On Mac with Docker driver, NodePort is not accessible directly → use `minikube service` or `minikube tunnel`
* Keep the terminal with `minikube tunnel` open while using Ingress
* Verify that Ingress resolves correctly:
```bash
ping fofatafo.local
```
Should respond with `127.0.0.1`.

---
