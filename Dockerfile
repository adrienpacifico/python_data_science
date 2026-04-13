FROM python:3.13-slim
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    git \
    nano \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
USER docker

WORKDIR /home/docker/app
COPY --chown=docker:docker pyproject.toml uv.lock ./
RUN uv sync --frozen

CMD ["uv", "run", "jupyter", "lab", "--collaborative", "--ip", "0.0.0.0"]
