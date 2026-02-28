{ lib, pkgs, ... }:
{
  # Keep as an explicit module so darwin-specific package overrides can be added
  # without touching shared configuration.
  home.packages = lib.optionals pkgs.stdenv.isDarwin [ ];
}
