{ pkgs }:

let
  core = import ./packages-core.nix { inherit pkgs; };
in
core
