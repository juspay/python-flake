{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    python-flake.url = "path:../."; # TODO: use a proper flake once upstreamed
    just-flake.url = "github:juspay/just-flake";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      debug = true;
      imports = [
        inputs.git-hooks.flakeModule
        inputs.just-flake.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { pkgs, config, ... }: {
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            treefmt.enable = true;
            convco.enable = true;
          };
        };
        treefmt.config = {
          projectRoot = inputs.python-flake;
          projectRootFile = "flake.nix";
          flakeCheck = false; # pre-commit-hooks.nix checks this
          programs.nixpkgs-fmt.enable = true;
        };
        just-flake.features = {
          treefmt.enable = true;
          convco.enable = true;
        };
        devShells.default = pkgs.mkShell {
          name = "python-flake";
          # cf. https://community.flake.parts/haskell-flake#composing-devshells
          inputsFrom = [
            config.just-flake.outputs.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];
          packages = [
            config.pre-commit.settings.tools.convco
          ];
        };
      };
    };
}
