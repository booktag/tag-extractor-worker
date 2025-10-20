# === Stage 1: build deps ===
FROM python:3.13.5-alpine AS builder
WORKDIR /build

ENV POETRY_VERSION=2.2.1
RUN apk add --no-cache build-base
RUN pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock* ./

# Force Poetry to put venv inside project
RUN poetry config virtualenvs.in-project true

# Install only main deps
RUN poetry install --no-interaction --no-ansi --only main

# === Stage 2: runtime ===
FROM python:3.13.5-alpine
WORKDIR /tag-extractor-worker
ENV PYTHONUNBUFFERED=1

# Copy the venv from builder
COPY --from=builder /build/.venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy project code
COPY . .

CMD ["python", "app/main.py"]
