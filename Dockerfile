# Ubuntu 24.04 base for dotfiles testing
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
    golang-go \
    locales \
    openssh-client \
    pkg-config \
    python3-dev \
    sudo \
    tzdata \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale for interactive shells
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Set timezone to JST
RUN ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && echo Asia/Tokyo > /etc/timezone

# Install chezmoi (only tool pre-installed)
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Workspace mount point
WORKDIR /workspace

# Default shell
SHELL ["/bin/bash", "-lc"]

# Default terminal capabilities
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

CMD ["bash"]