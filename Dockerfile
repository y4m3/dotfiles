# Ubuntu 24.04 base for dotfiles testing
# Note: Currently only Ubuntu 24.04 is supported. Platform-specific changes
# may be needed if support for other platforms is added in the future.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# Install only essential tools for chezmoi and bash execution
# run_once_ scripts will handle additional tools on host systems
RUN apt-get update && apt-get install -y \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    direnv \
    jq \
    locales \
    openssh-client \
    pkg-config \
    python3-dev \
    tmux \
    sudo \
    tzdata \
    unzip \
    vim-gtk3 \
    && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale for interactive shells
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Set timezone to JST
RUN ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && echo Asia/Tokyo > /etc/timezone

# Install chezmoi (only tool pre-installed)
# Install to $HOME/.local/bin to match host environment behavior
RUN mkdir -p /root/.local/bin && \
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /root/.local/bin

# Add /root/.local/bin to PATH so chezmoi is available immediately
ENV PATH="/root/.local/bin:${PATH}"

# Workspace mount point
WORKDIR /workspace

# Default shell
SHELL ["/bin/bash", "-lc"]

# Default terminal capabilities
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

CMD ["bash"]