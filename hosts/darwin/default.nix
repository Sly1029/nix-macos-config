{ agenix, config, pkgs, ... }:

let user = "rohit"; in

{

  imports = [
    # ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    # agenix.darwinModules.default
  ];

  # Setup user, packages, programs
  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ 
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" 
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    # agenix.packages."${pkgs.system}".default
    htop
    pkg-config
    neovim
    ripgrep
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });
  
  # Configure fonts
  fonts.packages = with pkgs; [ fira-code source-code-pro ];
  
  # Add brew shell path
  environment.pathsToLink = [ "/share/zsh" ];
  
  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };
  
  # Fix for macOS Sequoia - adjust GID if future macOS versions change it
  ids.gids.nixbld = 350;

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
