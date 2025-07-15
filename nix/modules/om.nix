{
  ci.default =
    let
      overrideInputs = {
        python-flake = ./.;
      };
    in
    {
      dev = { inherit overrideInputs; dir = "dev"; };
    };
  health.default = {
    nix-version.supported = ">=2.16.0";
    caches.required = [ "https://om.cachix.org" ];
    direnv.required = true;
    homebrew.required = true;
  };
}
