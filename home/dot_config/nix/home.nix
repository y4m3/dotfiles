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
    gitmux
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
    nil # Nix LSP; Mason auto-install disabled
    nixfmt
    prettier
    cspell
    pyright # Mason auto-install disabled; managed here for version consistency
    ruff # Mason auto-install disabled; managed here for version consistency
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

  home.sessionVariables = {
    TZ = "Asia/Tokyo";
  };

  programs.home-manager.enable = true;
}
