{
  inputs.livebook = {
    url = "github:livebook-dev/livebook/v0.9.2";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        erlangVersion = "erlangR24";
        elixirVersion = "elixir_1_14";

        beamPackages = pkgs.beam.packages.${erlangVersion};
      in rec {
        packages =
          beamPackages.callPackage ./release.nix
          {
            pname = "livebook";
            version = "0.9.2";
            src = inputs.livebook.outPath;
            elixir = beamPackages.${elixirVersion};
          };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            beamPackages.erlang
            beamPackages.${elixirVersion}
          ];

          nativeBuildInputs = [
            self.packages.${system}.default
          ];

          shellHook = ''
            export RELEASE_COOKIE=$(cat /dev/urandom | env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
          '';
        };
      }
    );
}
