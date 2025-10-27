# syntax=docker/dockerfile:1
# ------------------------------
# 1️⃣ Base image
# ------------------------------
FROM python:3.10-slim AS base

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create working directory
WORKDIR /app

# ------------------------------
# 2️⃣ Install dependencies
# ------------------------------
COPY requirements.txt .

# Install dependencies (without cache to keep image small)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential curl \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------
# 3️⃣ Copy application code & model
# ------------------------------
COPY app.py .
COPY model.joblib .         # or model_pipeline.joblib (whichever you want to use)
# You can include both if needed
# COPY model_pipeline.joblib .

# ------------------------------
# 4️⃣ Create a non-root user (security best practice)
# ------------------------------
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# ------------------------------
# 5️⃣ Expose port & define environment variables
# ------------------------------
EXPOSE 8080
ENV PORT=8080
ENV MODEL_PATH=model.joblib

# ------------------------------
# 6️⃣ Healthcheck for container orchestration (K8s, Docker, etc.)
# ------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# ------------------------------
# 7️⃣ Run the API using Gunicorn (production WSGI server)
# ------------------------------
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app", "--workers", "2", "--threads", "4"]
