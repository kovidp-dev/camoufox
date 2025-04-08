# Use a stable Ubuntu version (20.04 works reliably)
FROM ubuntu:20.04

# Set noninteractive mode to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Copy all repository files into the container
COPY . /app

# Install necessary packages and clean up caches in one layer
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    msitools \
    wget \
    unzip \
    rustc \
    python3 \
    python3-dev \
    python3-pip \
    git \
    p7zip-full \
    golang-go \
    aria2 \
    curl \
    rsync \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup in silent mode and update PATH
RUN curl -fsSL https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Optional: Force a specific rust toolchain version if needed, e.g.:
# RUN rustup default stable

# Run initial Camoufox setup: fetch Firefox source, apply patches, etc.
RUN make setup-minimal && \
    make mozbootstrap && \
    mkdir -p /app/dist

# Declare volumes for persistent build cache and artifacts
VOLUME ["/root/.mozbuild", "/app/dist"]

# Set default entrypoint (for building packages with multibuild.py)
ENTRYPOINT ["python3", "./multibuild.py"]
