{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;

  erlang = beam.interpreters.erlangR21.override {
    # Temporary fix to enable use on OS X El Capitan.
    enableKernelPoll = if stdenv.isDarwin then false else true;
  };

  elixir = (beam.packages.erlangR21.override { inherit erlang; }).elixir_1_7;
in

mkShell {
  buildInputs = [ elixir git ];
}
