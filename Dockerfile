# Use a specific official Python runtime digest for reproducibility
FROM python@sha256:85824326bc4ae27a1abb5bc0dd9e08847aa5fe73d8afb593b1b45b7cb4180f57

# Add metadata labels
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="My Python web application using Gunicorn"
LABEL version="1.0"

# Set the working directory in the container
WORKDIR /app

# Create a non-root user and group first
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --ingroup appgroup --shell /sbin/nologin --no-create-home appuser

# Install Poetry
ENV POETRY_VERSION=2.1.2
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry-venv
ENV POETRY_CACHE_DIR=/opt/.cache

# Install Poetry and its dependencies
RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry==${POETRY_VERSION}

# Add Poetry to PATH
ENV PATH="${PATH}:${POETRY_VENV}/bin"

# Copy poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root

# Copy the application code
COPY main.py .

# Set proper permissions
RUN chown -R appuser:appgroup /app

# Expose port 8080 for the app
EXPOSE 8080

# Switch to the non-root user
USER appuser

# Run the app with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]