# Use a specific official Python runtime digest for reproducibility
# Find the latest digest using 'docker pull python:3.12-slim' and 'docker images --digests python'
FROM python@sha256:85824326bc4ae27a1abb5bc0dd9e08847aa5fe73d8afb593b1b45b7cb4180f57

# Add metadata labels
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="My Python web application using Gunicorn"
LABEL version="1.0"

# Set the working directory in the container
WORKDIR /app

# Create a non-root user and group first
# Using fixed UID/GID is good practice for predictable permissions
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --ingroup appgroup --shell /sbin/nologin --no-create-home appuser

# Install dependencies
# Copy requirements first to leverage Docker cache
COPY requirements.txt .
# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --requirement requirements.txt


# Copy the current directory contents into the container
# Use --chown to set permissions directly (requires BuildKit and newer Docker)
COPY main.py .
RUN chown appuser:appgroup main.py


# Expose port 8000 for the app
EXPOSE 8000

# Switch to the non-root user
USER appuser

# Run the app with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app"]