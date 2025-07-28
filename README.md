# python-flake

A simple flake module for Python development, based on [uv2nix](https://pyproject-nix.github.io/uv2nix/). `python-flake` is inspired by [`haskell-flake`](https://github.com/srid/haskell-flake).

# Examples

- Coming up ...

#### Example Quick DevShell

```nix
{
  description = "Flake to do python stuff ...... 🐍 ❄ ";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    python-flake.url = "path:../.";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = import inputs.systems;
      imports = [ inputs.python-flake.flakeModules.default ];
      perSystem = { pkgs, config, ... }: {
        python-project = {
          name = "test";
          root = ./.;
          pythonVersionFile = true;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.devShells.uv2nix ];
        };
      };
    };
}
```
