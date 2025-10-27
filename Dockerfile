# Dockerfile — Simple runtime image (fast, fewer build errors)
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10

WORKDIR /app

# Install Python deps
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /app/requirements.txt

# Copy code + model
COPY . /app

ENV PORT=8080
EXPOSE 8080
# base image manages the server process automatically
