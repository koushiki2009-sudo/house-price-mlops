# ===============================
# Dockerfile for house-price-mlops
# ===============================

# Use a lightweight Python image
FROM python:3.10-slim-bullseye

# Prevents Python from buffering stdout/stderr
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# -------------------------------------
# Install essential system dependencies
# -------------------------------------
# (Add more later if a package requires it)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------
# Copy requirements file and install deps
# -------------------------------------
COPY requirements.txt /app/requirements.txt

# Upgrade pip, then install each package individually to show which fails
RUN python -m pip install --upgrade pip setuptools wheel && \
    echo "=== Installing requirements one by one ===" && \
    python - <<'PY'
import sys, subprocess
reqs = open('/app/requirements.txt').read().splitlines()
for r in reqs:
    r = r.strip()
    if not r or r.startswith('#'):
        continue
    print(f"\n>>> Installing: {r}\n", flush=True)
    rc = subprocess.call([sys.executable, "-m", "pip", "install", "--no-cache-dir", r])
    if rc != 0:
        print(f"!!! FAILED TO INSTALL: {r}", flush=True)
        sys.exit(rc)
print("✅ All packages installed successfully!", flush=True)
PY

# -------------------------------------
# Copy the rest of your project files
# -------------------------------------
COPY . /app

# Expose port (FastAPI / Flask default)
EXPOSE 8080
ENV PORT=8080

# -------------------------------------
# Start the app
# -------------------------------------
# Change this line if your app file or variable name is different.
# Example: If your main file is `app.py` and FastAPI instance is `app`
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app:app", "-b", "0.0.0.0:8080", "-w", "1"]
