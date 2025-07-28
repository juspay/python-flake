{
  ci.default =
    let
      overrideInputs = {
        python-flake = ./.;
      };
    in
    {
      dev = { inherit overrideInputs; dir = "dev"; };
      simple = { inherit overrideInputs; dir = "./examples/simple"; };
    };
  health.default = {
    nix-version.supported = ">=2.16.0";
    caches.required = [ "https://om.cachix.org" ];
    direnv.required = true;
    homebrew.required = true;
  };
}
