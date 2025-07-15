{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    just-flake.url = "github:juspay/just-flake";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.flake = false;
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      debug = true;
      imports = [
        (inputs.git-hooks + /flake-module.nix)
        inputs.just-flake.flakeModule
      ];

      perSystem = { pkgs, config, ... }: {
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            nixpkgs-fmt.enable = true;
            convco.enable = true;
          };
        };
        just-flake.features = {
          convco.enable = true;
        };
        devShells.default = pkgs.mkShell {
          name = "python-flake";
          # cf. https://community.flake.parts/haskell-flake#composing-devshells
          inputsFrom = [
            config.just-flake.outputs.devShell
            config.pre-commit.devShell
          ];
          packages = [
            config.pre-commit.settings.tools.convco
          ];
        };
      };
    };
}
