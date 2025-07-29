{
  description = "A `flake-parts` module for Python development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";

    uv2nix.url = "github:pyproject-nix/uv2nix";
    uv2nix.inputs.pyproject-nix.follows = "pyproject-nix";
    uv2nix.inputs.nixpkgs.follows = "nixpkgs";

    pyproject-build-systems.url = "github:pyproject-nix/build-system-pkgs";
    pyproject-build-systems.inputs.pyproject-nix.follows = "pyproject-nix";
    pyproject-build-systems.inputs.uv2nix.follows = "uv2nix";
    pyproject-build-systems.inputs.nixpkgs.follows = "nixpkgs";

    uv2nix_hammer_overrides.url = "github:TyberiusPrime/uv2nix_hammer_overrides";
    uv2nix_hammer_overrides.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { pyproject-nix, pyproject-build-systems, uv2nix, uv2nix_hammer_overrides, ... }:
    let
      # Preserve name and key of the module file for dedup and error message locations
      import' =
        modulePath: staticArg:
        {
          key = toString modulePath;
          _file = toString modulePath;
          imports = [ (import modulePath staticArg) ];
        };
    in
    {
      om = import ./nix/modules/om.nix;
      flakeModules = {
        default = import' ./nix/modules/flake-module.nix { inherit pyproject-nix pyproject-build-systems uv2nix uv2nix_hammer_overrides; };
      };
    };
}
