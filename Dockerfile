FROM tiangolo/uvicorn-gunicorn-fastapi:python3.10
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip setuptools wheel && pip install --no-cache-dir -r /app/requirements.txt
COPY . /app
ENV PORT=8080
EXPOSE 8080
