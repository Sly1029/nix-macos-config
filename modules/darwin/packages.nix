{ pkgs }:

with pkgs;
let
  core = import ../shared/packages-core.nix { inherit pkgs; };
in
core ++ [
  # Darwin specific
  dockutil
  unnaturalscrollwheels
  discord
  spotify
]
