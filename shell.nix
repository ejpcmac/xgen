{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;

  elixir = beam.packages.erlangR21.elixir_1_7;
  gitflow = gitAndTools.gitflow;
in

mkShell {
  buildInputs = [ elixir git gitflow ];
}
