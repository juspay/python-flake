{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.flake = false;
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      debug = true;
      imports = [
        (inputs.git-hooks + /flake-module.nix)
      ];

      flake.om.develop.default.readme = # md
        ''
          `Hint`: Run `just` to see what's available
        '';
      perSystem = { pkgs, config, ... }: {
        pre-commit = {
          check.enable = true;
          settings.hooks.nixpkgs-fmt.enable = true;
        };
        devShells.default = pkgs.mkShell {
          name = "python-flake";
          # cf. https://community.flake.parts/haskell-flake#composing-devshells
          inputsFrom = [
            config.pre-commit.devShell
          ];
          packages = with pkgs;[
            just
          ];
        };
      };
    };
}
