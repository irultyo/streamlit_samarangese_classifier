# Stage 1: Build environment
FROM ghcr.io/astral-sh/uv:latest

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml uv.lock ./
COPY app.py ./
COPY model.h5 ./

# Create a virtual environment and sync dependencies using uv
RUN uv sync --frozen

# Expose the port Streamlit will run on
EXPOSE 5003

# Set the entrypoint to run the Streamlit app
CMD ["uv", "run", "streamlit", "run", "/app/app.py", "--server.port=5003", "--server.address=0.0.0.0"]