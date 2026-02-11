{ pkgs }:

with pkgs; [
  # CLI and dev tooling (cross-platform)
  awscli2
  btop
  bun
  cachix
  curl
  delta
  direnv
  fd
  ffmpeg
  fzf
  gh
  git-lfs
  htop
  jq
  k9s
  kubectl
  kustomize
  nixfmt
  pkg-config
  pcre
  pnpm
  poetry
  pre-commit
  protobuf
  starship
  terraform
  time
  tmux
  tree-sitter
  uv
  wget
  yarn
  zoxide

  # Language servers / dev extras
  nodePackages.typescript-language-server
  nil
  pyright
  lua-language-server

  # Search
  ripgrep
]

