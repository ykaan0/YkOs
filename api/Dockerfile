FROM python:3.11-alpine

# Docker CLI ve temel araçları yükle (Docker escape pratiği için)
RUN apk add --no-cache docker-cli iputils bash curl

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
