{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";

    # TODO sort by category
    packages = with pkgs;
      [
        awscli2
        btop
        cachix
        curl
        docker
        docker-compose
        fd
        ffmpeg
        fzf
        gh
        git-lfs
        jq
        kubectl
        kustomize
        nodejs
        nixfmt
        oh-my-zsh
        opam
        pcre
        poetry
        pre-commit
        protobuf
        spotify
        time
        tree-sitter
        uv
        wget
        yarn
        zsh-autosuggestions
        zsh-syntax-highlighting
      ] ++ (with pkgs.nodePackages; [ typescript-language-server ]);
  };
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      sessionVariables = {
        PATH = "$HOME/.local/bin:$PATH";
        AWS_PROFILE = "engineer";
      };
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      autosuggestion.enable = true;

      shellAliases = {
        ll = "ls -ltrh --color=auto";
        ls = "${pkgs.lsd}/bin/lsd";
        rebuild =
          "darwin-rebuild switch --flake $HOME/Code/Personal/Nix/ && source ~/.zshrc";
      };
      oh-my-zsh = {
        enable = true;

        plugins = [
          "git"
          "colored-man-pages"
          "command-not-found"
          "docker"
          "npm"
          "pep8"
          "pip"
          "python"
          "sudo"
          "fzf"
        ];
      };
      initExtra = ''
        ## Advanced shell functions
        function rgd() {
          ${pkgs.ripgrep}/bin/rg --json -C 2 "$@" | ${pkgs.delta}/bin/delta
        }
        function login-aws() {
          ${pkgs.awscli2}/bin/aws sso login --sso-session semgrep
          ${pkgs.awscli2}/bin/aws ecr get-login-password | ${pkgs.docker}/bin/docker login --username AWS --password-stdin 338683922796.dkr.ecr.us-west-2.amazonaws.com
        }

        # eval opam if we arent in the semgrep flake dir
        if [[ -z "''${SEMGREP_NIX_BUILD-}" ]]; then
          eval $(opam env)
        fi

        # Set up homebrew
        export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH";
        # Doesn't work when set in session vars for some reason
        # check if cwd = /
        if [ "$PWD" = "/" ]; then
          cd ~
        fi
      '';
      profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
