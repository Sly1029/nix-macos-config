{ pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  
  nix.enable = false;
  environment = {
    systemPackages = with pkgs; [
      htop
      pkg-config
      neovim
      ripgrep
    ];
    pathsToLink = [ "/share/zsh" ];
  };
  fonts.packages = with pkgs; [ fira-code source-code-pro ];
  homebrew = {
    enable = true;
    brews = [
      {
        name = "semgrep/infra/libxmlsec1@1.2.37";
        link = true;
        conflicts_with = [ "libxmlsec1" ];
      }
    ];
    caskArgs.appdir = "~/Applications";
    casks = [
      "aws-vpn-client-semgrep"
      "betterdisplay"
      "ghostty"
      "font-hack-nerd-font"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono"
      "orbstack"
      "raycast"
      "zen-browser"
    ];
    taps = [{
      name = "semgrep/infra";
      clone_target = "git@github.com:semgrep/homebrew-infra.git";
    }];
  };

  nix.settings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes";
    trusted-substituters = [ "rohitjayaram" ];

    substituters =
      [ "https://nix-community.cachix.org" "https://semgrep.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "semgrep.cachix.org-1:waxSNb3ism0Vkmfa31//YYrOC2eMghZmTwy9bvMAGBI="
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;
  system.defaults = {
    dock = {
      # TODO: persistent-apps
      autohide = false;
      show-recents = true;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
}
