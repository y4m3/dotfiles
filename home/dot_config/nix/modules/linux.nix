{ lib, pkgs, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux [
    # WSL utilities
    pkgs.wslu
  ];
}
