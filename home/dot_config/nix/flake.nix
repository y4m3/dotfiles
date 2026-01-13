# Home Manager configuration for chezmoi-managed dotfiles
#
# Uses `builtins.getEnv` for dynamic username/home detection, which requires
# the `--impure` flag when evaluating the flake.
#
# Usage:
#   home-manager switch --flake ~/.config/nix --impure
{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Dynamic username from $USER environment variable (requires --impure)
      username = builtins.getEnv "USER";
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
