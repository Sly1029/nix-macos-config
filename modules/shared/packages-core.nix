{ pkgs }:

with pkgs; [
  # CLI and dev tooling (cross-platform)
  awscli2
  btop
  bun
  cachix
  curl
  direnv
  fd
  ffmpeg
  fzf
  gh
  git-lfs
  htop
  jq
  kubectl
  kustomize
  neovim
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

  # Search
  ripgrep
]

