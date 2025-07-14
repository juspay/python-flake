{
  description = "A `flake-parts` module for Python development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ ... }: {
    om.ci.default =
      let
        overrideInputs = {
          python-flake = ./.;
        };
      in
      {
        dev = { inherit overrideInputs; dir = "dev"; };
      };
  };
}
