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
        graphite-cli
        jq
        kubectl
        kustomize
        nodejs
        nixfmt
        oh-my-zsh
        opam
        ollama
        pcre
        poetry
        pre-commit
        protobuf
        spotify
        starship
        time
        tmux
        tree-sitter
        unnaturalscrollwheels
        uv
        wget
        yarn
        zsh-autosuggestions
        zsh-syntax-highlighting
        zoxide
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
    lsd = {
      enable = true;
      settings = {
        classic = false;
        blocks = [
          "permission"
          "name"
          "size"
          "date"
        ];
        color.when = "auto";
        date = "date";
        dereference = false;
        icons = {
          when = "never";
          theme = "fancy";
          separator = " ";
        };
        indicators = false;
        layout = "grid";
        recursion.enabled = false;
        size = "default";
        sorting = {
          column = "name";
          reverse = false;
          dir-grouping = "first";
        };
        no-symlink = false;
        total-size = false;
        hyperlink = "never";
        symlink-arrow = "⇒";
        header = false;
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting.enable = true;

      sessionVariables = {
        PATH = "$HOME/.local/bin:$HOME/.apps:$HOME/.cargo/bin:$PATH";
        EDITOR = "nvim";
      };

      shellAliases = {
        ll = "${pkgs.lsd}/bin/lsd -l";
        ls = "${pkgs.lsd}/bin/lsd";
        la = "${pkgs.lsd}/bin/lsd -la";
        rebuild = "darwin-rebuild switch --flake $HOME/Code/Personal/Nix/ && source ~/.zshrc";
        vim = "nvim";
        vi = "nvim";
        s = "git status";
        frontend = "docker run -it --workdir /app -v $(pwd)/src:/app/src -v $(pwd)/libs:/app/libs --network host semgrep-frontend make run";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "colored-man-pages"
          "command-not-found"
          "docker"
          "npm"
          "python"
          "sudo"
          "fzf"
        ];
        theme = "";
      };

      initExtra = ''
        # Source AWS config if it exists
        [[ -f ~/.aws-config.zsh ]] && source ~/.aws-config.zsh

        # Enable vi mode
        bindkey -v

        # Enable command editing in editor
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd 'vv' edit-command-line

        # Custom functions
        function setenvlocal() {
          export $(grep -v '^#' $1 | xargs)
        }

        function del() {
          for f in "$@"; do
            mv -f "$f" "/tmp/$f"
          done
        }

        function git_search() {
          git log --patch | less +/$1
        }

        function gch() {
          local branches branch
          branches=$(git branch -vv --sort=-committerdate) &&
          branch=$(echo "$branches" | fzf +m) &&
          git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
        }

        # Initialize zoxide
        eval "$(zoxide init zsh)"

        # Initialize starship
        eval "$(starship init zsh)"

        # eval opam if we arent in the semgrep flake dir
        if [[ -z "''${SEMGREP_NIX_BUILD-}" ]]; then
          eval $(opam env)
        fi

        # Set up homebrew
        export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
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
    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      extraConfig = ''
        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Use Alt-vim keys without prefix key to switch panes
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Split panes using v and s
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"

        # Reload tmux config
        bind r source-file ~/.tmux.conf \; display "Reloaded!"

        # Smart pane switching with awareness of Vim splits
        bind -n C-h run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-h) || tmux select-pane -L"
        bind -n C-j run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-j) || tmux select-pane -D"
        bind -n C-k run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-k) || tmux select-pane -U"
        bind -n C-l run "(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim$' && tmux send-keys C-l) || tmux select-pane -R"

        # Copy mode improvements
        bind-key / copy-mode \; send-key ?
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
        bind-key -T copy-mode MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"

        # Theme and Status Bar
        set -g status-position bottom
        set -g status-style "bg=#1a1b26,fg=#c0caf5"

        # Left status
        set -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1a1b26]"
        set -g status-left-length 200

        # Window status
        set -g window-status-current-format "#[fg=#1a1b26,bg=#7aa2f7] #I:#W #[fg=#7aa2f7,bg=#1a1b26]"
        set -g window-status-format " #I:#W "

        # Right status
        set -g status-right "#[fg=#7aa2f7,bg=#1a1b26]#[fg=#1a1b26,bg=#7aa2f7] %Y-%m-%d %H:%M "
        set -g status-right-length 200

        # Pane borders
        set -g pane-border-style "fg=#3b4261"
        set -g pane-active-border-style "fg=#7aa2f7"

        # Message style
        set -g message-style "fg=#7aa2f7,bg=#1a1b26"

        # Clock mode
        set -g clock-mode-colour "#7aa2f7"
        set -g clock-mode-style 24

        # Selection
        set -g mode-style "fg=#1a1b26,bg=#7aa2f7"
      '';
    };
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };
        git_branch = {
          symbol = "🌱 ";
          truncation_length = 20;
        };
        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow) ";
        };
        format = "$directory$git_branch$cmd_duration$character";
      };
    };
  };
}
