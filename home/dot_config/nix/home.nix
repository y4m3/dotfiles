# Home Manager package configuration
#
# Packages here are managed by Nix instead of apt/brew for:
# - Consistent versions across machines
# - Declarative, reproducible setup
# - Easy rollback via `home-manager generations`
{
  pkgs,
  ...
}:

let
  # Dynamic values from environment (requires --impure flag)
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
    starship
    tmux
    zellij

    # File operations
    bat
    eza
    fd
    fzf
    ripgrep
    yazi
    zoxide

    # Git tools
    delta
    gh
    ghq
    git
    lazygit

    # Development tools
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
    pyright # Mason auto-install disabled; managed here for version consistency
    ruff # Mason auto-install disabled; managed here for version consistency
    shellcheck
    shfmt
    sqlite # Required by snacks.picker for frecency/history
    tectonic
    uv
    yq-go

    # Image processing for snacks.image (LazyVim)
    ghostscript
    imagemagick

    # Runtimes
    deno
    nodejs_22

    # Japanese input (SKK) for skkeleton/blink-skkeleton
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
