FROM python:3.12-slim-bookworm

# The installer requires curl (and certificates) to download the release archive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.cargo/bin/:$PATH"

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