pythonFlakeInputs:
{ flake-parts-lib, lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ pkgs, config, ... }: {
        imports = [ (import ./devshell.nix pythonFlakeInputs) ];
        options = {
          python-project = {
            name = lib.mkOption {
              description = "Name of the Python project.";
              type = lib.types.str;
            };
            pythonVersionFile = lib.mkEnableOption "pythonVersionFile" // {
              description = ''
                If enabled, the Python version will be read from a file named
                `python-version` in the project root. This is useful for projects
                that require a specific Python version.
              '';
              default = false;
            };
            python = lib.mkOption {
              description = ''
                The Python interpreter to use for the project.
                This is used to run the build system and other Python-related tasks.
              '';
              type = lib.types.package;
              default =
                if config.python-project.pythonVersionFile then
                  let
                    pythonVersionFile = config.python-project.root + /.python-version;
                    DEFAULT_PYTHON_MAJOR_VERSION = "3";
                    versionStr =
                      with builtins;
                      with lib;
                      let
                        raw = if pathExists pythonVersionFile then readFile pythonVersionFile else "";
                        m = match "([0-9]+)\\.([0-9]+).*" (removeSuffix "\n" raw); # ["3" "13"]
                      in
                      if m != null && m != [ ] then concatStringsSep "" m else DEFAULT_PYTHON_MAJOR_VERSION;
                  in
                  pkgs."python${versionStr}"
                else
                  pkgs.python3;
            };
            overrides = lib.mkOption {
              type = lib.types.functionTo (lib.types.functionTo (lib.types.attrs));
              default = final: prev: { };
              description = lib.mdDoc ''
                A function of the form `final: prev: { ... }` to override Python packages.

                The function receives two arguments:
                - `final`: The final package set after applying all overrides
                - `prev`: The previous package set before this override

                You can add multiple package overrides inside this single function.

                Example:
                ```
                final: prev: {
                  requests = prev.requests.overridePythonAttrs (old: {
                    doCheck = false;
                  });

                  numpy = prev.numpy.override {
                    blas = final.openblas;
                  };
                }
                ```
              '';
              example = lib.literalExpression ''
                final: prev: {
                  requests = prev.requests.overridePythonAttrs (old: {
                    doCheck = false;
                  });
                }
              '';
            };
            root = lib.mkOption {
              description = ''
                Path to the root of the Python project.
                This is used to determine where to look for the `pyproject.toml`
                file and other project-related files.
              '';
              type = lib.types.path;
            };
            sourcePreference = lib.mkOption {
              type = lib.types.enum [ "wheel" "sdist" ];
              description = ''
                Preference for the source type to use when building the project.
                "wheel" will prefer building from a wheel if available, while
                "sdist" will prefer building from a source distribution.
              '';
              default = "wheel";
            };
          };
        };
      });
  };
}
