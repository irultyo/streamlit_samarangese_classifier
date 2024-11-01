# Stage 1: Build environment
FROM python:3.12-slim AS builder

# Install curl and uv
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY streamlit_app.py ./

# Create a virtual environment and install dependencies using uv
RUN ~/.cargo/bin/uv venv /app/venv
RUN ~/.cargo/bin/uv add \
    streamlit \
    pillow \
    opencv-python-headless \
    tensorflow \
    numpy

# Stage 2: Production image using distroless
FROM gcr.io/distroless/python3-debian12

# Copy virtual environment from builder
COPY --from=builder /app/venv /venv

# Copy application files
COPY --from=builder /app/streamlit_app.py /app/streamlit_app.py

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PATH="/venv/bin:$PATH" \
    VIRTUAL_ENV="/venv"

# Expose the port Streamlit will run on
EXPOSE 5003

# Set the entrypoint to run the Streamlit app
ENTRYPOINT ["streamlit", "run", "/app/streamlit_app.py", "--server.port=5003", "--server.address=0.0.0.0"]