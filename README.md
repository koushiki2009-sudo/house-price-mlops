# 🏠 House Price MLOps

End-to-end sample for an ML-powered microservice with Docker, Kubernetes, Kubeflow, Prometheus, and Grafana.

## 📁 Files
- `app.py` – Flask API exposing `/predict`, `/healthz`, `/readyz`, `/metrics`
- `model.joblib` – trained model
- `requirements.txt` – dependencies
- `Dockerfile` – container build
- `k8s_deployment.yaml`, `k8s_service.yaml` – Kubernetes manifests
- `kubeflow_pipeline.py` – Kubeflow Pipelines SDK example
- `prometheus.yml` – Prometheus scrape configuration
- `grafana_dashboard.json` – Grafana dashboard
- `.github/workflows/docker-build.yml` – GitHub Actions workflow to build and push Docker image

## 🚀 Local run
```bash
docker build -t house-model:latest .
docker run -p 8080:8080 house-model:latest
