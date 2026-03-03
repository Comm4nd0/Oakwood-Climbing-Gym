# Build stage
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-prod.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements-prod.txt

# Production stage
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home appuser

COPY --from=builder /install /usr/local

COPY --chown=appuser:appuser . .

RUN mkdir -p /app/staticfiles && chown appuser:appuser /app/staticfiles
RUN mkdir -p /app/media && chown appuser:appuser /app/media

# Collect static files during build
RUN SECRET_KEY=temp-build-key \
    DB_NAME=temp \
    DB_HOST=localhost \
    python manage.py collectstatic --noinput 2>/dev/null || true

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/admin/')" || exit 1

CMD ["gunicorn", "climbing_gym_backend.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "2"]
