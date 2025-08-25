{ pkgs }:

with pkgs; [
  awscli2
  btop
  bun
  cachix
  curl
  cyberduck
  direnv
  discord
  fd
  ffmpeg
  fzf
  gh
  git-lfs
  jq
  kubectl
  kustomize
  neovim
  nixfmt
  oh-my-zsh
  ollama
  pcre
  pnpm
  poetry
  pre-commit
  protobuf
  spotify
  starship
  terraform
  time
  tmux
  tree-sitter
  unnaturalscrollwheels
  uv
  wget
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zoxide

  # Node.js packages from your original config
  nodePackages.typescript-language-server

  # Essential system tools (minimal set)
  htop
  ripgrep
]
