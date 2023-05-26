# Nix Flake for Running Livebook

This is a Nix flake for running [Elixir Livebook](https://livebook.dev/) locally
without installation.

## Usage
Set `LIVEBOOK_IP` and `LIVEBOOK_HOME` environment variables and run a Nix shell:

``` shell
export LIVEBOOK_IP=0.0.0.0
# Specify the directory in which documents are saved by default
export LIVEBOOK_HOME=$PWD/doc
# Optional; store the application data to a non-default location, e.g. the
# project root
export HOME=$PWD

nix develop github:akirak/livebook-flake -c livebook start
```

### Devenv with flake integration
It is also possible to integrate Livebook into a
[devenv](https://devenv.sh/guides/using-with-flakes/)-enhanced flake. This way,
you can run other background processes simultaneously with Livebook using the
process management feature of devenv.

First add the following shell to `flake.nix`:

``` nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    livebook-flake.url = "github:akirak/livebook-flake";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    flake-utils,
    livebook-flake,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.livebook = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = with (livebook-flake.packages.${system}); [
                erlang
                elixir
                livebook
              ];

              processes.livebook.exec = ''
                HOME="$root/livebook" livebook start
              '';

              enterShell = ''
                export root="$(git rev-parse --show-toplevel)"

                export LIVEBOOK_IP=0.0.0.0
                export LIVEBOOK_HOME="$root/livebook/doc"

                export RELEASE_COOKIE=$(cat /dev/urandom | \
                  env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
              '';
            }
          ];
        };
      }
    );
}
```

Now you enter the shell:

``` shell
nix develop .#livebook --impure
```

Create a directory that you set as `LIVEBOOK_HOME`:

``` shell
mkdir -p livebook/doc
```

Start Livebook (and other processes specified within the same shell):

``` shell
devenv up
```
