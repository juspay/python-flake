pythonFlakeInputs:
{ config, pkgs, lib, ... }:
let
  inherit (pythonFlakeInputs) uv2nix uv2nix_hammer_overrides pyproject-nix pyproject-build-systems;
  inherit (config.python-project) overrides python root sourcePreference;
  cfg = config.python-project;

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = root; };
  pyprojectOverrides = lib.composeExtensions (uv2nix_hammer_overrides.overrides pkgs) overrides;
  overlay = workspace.mkPyprojectOverlay { inherit sourcePreference; };

  # ' represents the editable variant of uv2nix package
  overlay' = workspace.mkEditablePyprojectOverlay { root = "$REPO_ROOT"; };

  pythonSet =
    ((pkgs.callPackage pyproject-nix.build.packages
      { inherit python; }).overrideScope
      (lib.composeManyExtensions [
        pyproject-build-systems.overlays.default
        overlay
      ])).pythonPkgsHostHost.overrideScope pyprojectOverrides;
  pythonSet' = pythonSet.overrideScope (lib.composeManyExtensions [
    overlay'
    # TODO: Expose to the user
    # Use a better fileset filter here.
    (final: prev: {
      "${cfg.name}" = prev.${cfg.name}.overrideAttrs (old: {
        src = cfg.root;
      });
    })
  ]);

in
{
  options.python-project = {
    pythonSet = lib.mkOption {
      type = lib.types.attrs;
      default = pythonSet;
      description = "The Python package set to use for the project.";
    };
    pythonSet' = lib.mkOption {
      type = lib.types.attrs;
      default = pythonSet';
      description = "The editable Python package set to use for the project.";
    };
    venv = lib.mkOption {
      type = lib.types.package;
      default = with cfg; pythonSet.mkVirtualEnv name workspace.deps.all;
      description = "The editable virtual environment for the project.";
    };
  };
  config = {
    packages = {
      # default package with non editable virtual environment, `pyproject.toml` should have a # `[project.scripts]` section to expose commands
      default = lib.mkDefault (pythonSet.mkVirtualEnv cfg.name workspace.deps.all);
    };
    devShells.uv2nix =
      pkgs.mkShell {
        name = "python-fake-devshell";
        meta.description = "Python development environment created by uv2nix";
        packages = [ pkgs.uv pkgs.just cfg.venv ];
        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = "${lib.getExe' cfg.venv "python"}";
          UV_PYTHON_DOWNLOADS = "never";
        };
        shellHook = # sh
          ''
            # Undo dependency propagation by nixpkgs.
            unset PYTHONPATH

            # Get repository root using git. This is expanded at runtime by the editable `.pth` machinery.
            export REPO_ROOT=$(git rev-parse --show-toplevel)

            echo "Python version: $(python --version)"
            echo ""
          '';
      };
  };
}
