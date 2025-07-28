{
  description = "Flake for Juspay-mcp python project.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    python-flake.url = "path:./../../.";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = import inputs.systems;
      imports = [ inputs.python-flake.flakeModules.default ];
      perSystem = { pkgs, config, ... }: {
        python-project = {
          name = "simple";
          root = ./.;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.devShells.uv2nix ];
        };
      };
    };
}
