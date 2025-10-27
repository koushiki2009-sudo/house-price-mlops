# Dockerfile - broader system libs to fix most pip compile errors
FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install common build dependencies and scientific libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    gfortran \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libpq-dev \
    libatlas-base-dev \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install each package one-by-one (keeps logs clear)
COPY requirements.txt /app/requirements.txt

RUN python -m pip install --upgrade pip setuptools wheel && \
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

# Copy rest of project
COPY . /app

EXPOSE 8080
ENV PORT=8080

# Adjust entrypoint if needed (FastAPI/uvicorn/gunicorn example)
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app:app", "-b", "0.0.0.0:8080", "-w", "1"]
