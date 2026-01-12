{ config, pkgs, lib, ... }:

let
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # Dotfiles management
    chezmoi

    # Shell & Terminal
    carapace
    starship
    tmux
    zellij

    # File operations
    bat
    eza
    fd
    fzf
    ripgrep
    trash-cli
    yazi
    zoxide

    # Git tools
    delta
    gh
    ghq
    git
    lazygit

    # Development
    ast-grep
    direnv
    glow
    jq
    just
    luarocks
    markdown-toc
    markdownlint-cli2
    mermaid-cli
    nixfmt-rfc-style
    prettier
    pyright
    ruff
    shellcheck
    shfmt
    sqlite
    tectonic
    tldr
    uv
    yq-go

    # Image processing (snacks.image)
    ghostscript
    imagemagick

    # Runtimes
    deno
    nodejs_22

    # Japanese input (SKK)
    skktools
    skkDictionaries.l

    # Docker
    lazydocker

    # Editor
    neovim

    # System monitoring
    btop
    lnav

    # Password manager
    keepassxc
  ];

  programs.home-manager.enable = true;
}
