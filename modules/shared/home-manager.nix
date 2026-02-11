{ config, pkgs, lib, ... }:

let name = "Rohit Jayaram";
    user = "rohit";
    email = "tihor29@gmail.com"; in
{
  imports = [ ./neovim.nix ];
  # Shared shell configuration
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = false;
      cdpath = [ "~/.local/share/src" ];
      history.size = 10000;
      sessionVariables = {
        PATH = "$HOME/.local/bin:$HOME/.apps:$HOME/.cargo/bin:$HOME/.orbstack/bin:/Users/rohit/.volta/bin:/opt/homebrew/opt/ruby/bin:/Users/rohit/.local/share/uv/tools/semgrep/lib/python3.13/site-packages/semgrep/bin/:$PATH";
        EDITOR = "nvim";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
      };
      shellAliases = {
        ll = "lsd -l";
        la = "lsd -la";
        rebuild = "cd ~/Code/Personal/nixos-config && nix run .#build-switch";
        vim = "nvim";
        vi = "nvim";
        s = "git status";
        frontend = "docker run -it --workdir /app -v $(pwd)/src:/app/src -v $(pwd)/libs:/app/libs --network host semgrep-frontend make run";
        search = "rg -p --glob '!node_modules/*'";
        pn = "pnpm";
        px = "pnpx";
        diff = "difft";
	nixconfig = "z nixos-config && nvim .";
      };
      initContent = ''
        # include .profile if it exists
      	[[ -f ~/.profile ]] && . ~/.profile

        [[ -f ~/.aws-config.zsh ]] && source ~/.aws-config.zsh

        bindkey -v

        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd 'vv' edit-command-line

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

        # Override lsd aliases to match original config
        alias la='lsd -la'

        eval "$(zoxide init zsh)"

        if [[ -z "''${SEMGREP_NIX_BUILD-}" ]] && command -v opam >/dev/null 2>&1; then
          eval $(opam env)
        fi

        export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

        # nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        if [ "$PWD" = "/" ]; then
          cd ~
        fi
        source ~/.custom.zsh

        # Re-bind ctrl+r for fzf history after vi mode
        if command -v fzf &> /dev/null; then
          source <(fzf --zsh)
          bindkey '^R' fzf-history-widget
        fi
      '';
    };

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        # commit.gpgsign = true; # Disabled until GPG key is set up
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    ssh = {
      enable = true;
      includes = [
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
          "/home/${user}/.ssh/config_external"
        )
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
          "/Users/${user}/.ssh/config_external"
        )
      ];
      matchBlocks = {
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${user}/.ssh/id_ed25519"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${user}/.ssh/id_ed25519"
            )
          ];
        };
      };
    };

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
    #    vim-tmux-navigator
    #    sensible
        yank
        prefix-highlight
    #    {
    #      plugin = power-theme;
    #      extraConfig = ''
    #         set -g @tmux_power_theme 'gold'
    #      '';
    #    }
    #    {
    #      plugin = resurrect; # Used by tmux-continuum

    #      # Use XDG data directory
    #      # https://github.com/tmux-plugins/tmux-resurrect/issues/348
    #      extraConfig = ''
    #        set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
    #        set -g @resurrect-capture-pane-contents 'on'
    #        set -g @resurrect-pane-contents-area 'visible'
    #      '';
    #    }
    #    {
    #      plugin = continuum;
    #      extraConfig = ''
    #        set -g @continuum-restore 'on'
    #        set -g @continuum-save-interval '5' # minutes
    #      '';
    #    }
      ];
      terminal = "screen-256color";
      prefix = "C-a";
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      # Use $SHELL instead of hardcoded path for better compatibility
      # shell = "${pkgs.zsh}/bin/zsh";
              extraConfig = ''
          # Set the default shell to use the current user's shell
          set -g default-shell "$SHELL"
          
          # Remove Vim mode delays
          set -g focus-events on

        # Enable full mouse support
        set -g mouse on

        # -----------------------------------------------------------------------------
        # Key bindings
        # -----------------------------------------------------------------------------

        # Unbind default keys
        unbind C-b
        unbind '"'
        unbind %

        # Split panes, vertical or horizontal
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind r source-file ~/.tmux.conf \; display "Reloaded!"

        # Move around panes with vim-like bindings (h,j,k,l)
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Smart pane switching with awareness of Vim splits.
        # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l

        # Additional bindings from your config
        bind-key / copy-mode \; send-key ?
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
        bind-key -T copy-mode MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"

        # Your custom theme
        set -g status-position bottom
        set -g status-style "bg=#1a1b26,fg=#c0caf5"
        set -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1a1b26]"
        set -g status-left-length 200
        set -g window-status-current-format "#[fg=#1a1b26,bg=#7aa2f7] #I:#W #[fg=#7aa2f7,bg=#1a1b26]"
        set -g window-status-format " #I:#W "
        set -g status-right "#[fg=#7aa2f7,bg=#1a1b26]#[fg=#1a1b26,bg=#7aa2f7] %Y-%m-%d %H:%M "
        set -g status-right-length 200
        set -g pane-border-style "fg=#3b4261"
        set -g pane-active-border-style "fg=#7aa2f7"
        set -g message-style "fg=#7aa2f7,bg=#1a1b26"
        set -g clock-mode-colour "#7aa2f7"
        set -g clock-mode-style 24
        set -g mode-style "fg=#1a1b26,bg=#7aa2f7"
        '';
      };

    # Add lsd configuration
    lsd = {
      enable = true;
      enableZshIntegration = false;  # Disable automatic zsh aliases
      settings = {
        classic = false;
        blocks = [ "permission" "name" "size" "date" ];
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

    # Add starship configuration
    starship = {
      enable = true;
      enableZshIntegration = true;
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

    # Add direnv configuration
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    # Add fzf configuration
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
