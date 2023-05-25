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
