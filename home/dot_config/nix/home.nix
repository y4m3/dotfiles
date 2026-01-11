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

    # Development
    direnv
    glow
    jq
    just
    shellcheck
    shfmt
    uv
    yq-go

    # Runtimes
    nodejs_22

    # Docker
    lazydocker

    # System monitoring
    btop
    lnav
  ];

  programs.home-manager.enable = true;
}
