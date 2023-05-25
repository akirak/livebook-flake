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
  devShells.livebook = devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      {
        packages = [
          beamPackages.erlang
          beamPackages.${elixirVersion}
          livebook
        ];

        processes.livebook.exec = ''
          HOME="$root/livebook" livebook start
        '';

        enterShell = ''
          export root="$(git rev-parse --show-toplevel)"

          # Use tailscale if you want to access the service from another
          # machine
          export LIVEBOOK_IP=127.0.0.1
          export LIVEBOOK_HOME="$root/livebook/doc"

          export RELEASE_COOKIE=$(cat /dev/urandom | \
            env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        '';
      }
    ];
  };
```

Now you enter the shell:

``` shell
nix develop .#livebook --impure
```

Start Livebook (and other processes specified within the same shell):

``` shell
devenv up
```
