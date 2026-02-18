FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists (cached layer - only rebuilds if this changes)
RUN apt-get update

# Install required packages for OpenWrt build
# This layer is cached unless package list above changes
RUN apt-get install -y --no-install-recommends \
    build-essential \
    ccache \
    ecj \
    fastjar \
    file \
    g++ \
    gawk \
    gettext \
    git \
    java-propose-classpath \
    libelf-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    python3 \
    python3-distutils \
    python3-setuptools \
    rsync \
    subversion \
    swig \
    unzip \
    wget \
    xsltproc \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create workspace directory
WORKDIR /openwrt

# Create non-root user for interactive work
RUN groupadd -g 1000 builder && \
    useradd -m -u 1000 -g builder -s /bin/bash builder && \
    chown -R builder:builder /openwrt

# Set up bash history persistence for non-root user
RUN mkdir -p /home/builder/.history && \
    chown -R builder:builder /home/builder/.history && \
    echo 'export HISTFILE=/home/builder/.history/.bash_history' >> /home/builder/.bashrc && \
    echo 'export HISTSIZE=10000' >> /home/builder/.bashrc && \
    echo 'export HISTFILESIZE=20000' >> /home/builder/.bashrc && \
    echo 'export HISTCONTROL=ignoredups:erasedups' >> /home/builder/.bashrc && \
    echo 'shopt -s histappend' >> /home/builder/.bashrc && \
    echo 'PROMPT_COMMAND=\"history -a; history -c; history -r; $PROMPT_COMMAND\"' >> /home/builder/.bashrc

# Switch to non-root user
USER builder

# Default command
CMD ["/bin/bash"]

