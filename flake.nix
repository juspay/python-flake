{
  description = "A `flake-parts` module for Python development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { ... }: {
    om = import ./nix/modules/om.nix;
    flakeModules = {
      default = ./nix/modules/flake-module.nix;
      nixpkgs = ./nix/modules/nixpkgs.nix;
    };
  };
}
