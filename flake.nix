{
  inputs = {
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    scientific-fhs = {
      url = "github:l3mon4d3/scientific-fhs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { inputs', system, ... }:
        let
          pkgs = import inputs.nixpkgs-unstable { inherit system; };
          fhs = inputs'.scientific-fhs.packages.scientific-fhs.override {
            inherit pkgs;
            enablePython = false;
            enableQuarto = false;
            enableJulia = false;
            enableConda = false;
            enableNVIDIA = false;
            extraPackages = with pkgs; [
              pixi
            ];
            extraProfile = ''
              # pixi may register new completions, and a non-interactive bash does not have complete -> just add it.
              # This is the easiest fix that ensures that the env is also sourced correctly for non-interactive usage.
              if ! shopt -q progcomp 2>/dev/null; then
                complete() { :; }
              fi
              eval "$(pixi shell-hook)"
            '';
          };
        in
        {
          packages.fhs = fhs;
          devShells.default = fhs.env;
        };
    };
}
