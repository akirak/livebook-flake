{
  inputs.systems.url = "github:nix-systems/default";

  inputs.livebook = {
    url = "github:livebook-dev/livebook/v0.9.2";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    eachSystem = lib.genAttrs (import systems);

    version = "0.9.2";
    erlangVersion = "erlangR25";
    elixirVersion = "elixir_1_14";

    mkScopeForSystem = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      beamPackages = pkgs.beam.packages.${erlangVersion};
    in
      beamPackages
      // {
        elixir = beamPackages.${elixirVersion};
      };
  in {
    packages = eachSystem (
      system:
        lib.filterAttrs (_: lib.isDerivation)
        (lib.callPackageWith (mkScopeForSystem system)
          ./release.nix {
            inherit version;
            src = inputs.livebook.outPath;
          })
    );

    devShells = eachSystem (
      system:
        lib.filterAttrs (_: lib.isDerivation)
        (lib.callPackageWith (mkScopeForSystem system)
          ({
            erlang,
            elixir,
          }: {
            default = nixpkgs.legacyPackages.${system}.mkShell {
              buildInputs = [
                erlang
                elixir
              ];

              nativeBuildInputs = [
                self.packages.${system}.default
              ];

              shellHook = ''
                export RELEASE_COOKIE=$(cat /dev/urandom \
                | env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
              '';
            };
          }) {})
    );
  };
}
