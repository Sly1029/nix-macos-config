{ config, pkgs, lib, home-manager, ... }:

let
  user = "rohit";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    taps = ["withgraphite/tap"];
    onActivation = { autoUpdate = true; cleanup = "zap"; };
    global.lockfiles = false;  # sets HOMEBREW_BUNDLE_NO_LOCK to avoid Nix store writes
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    # Force override existing files
    extraSpecialArgs = { inherit pkgs; };
    sharedModules = [
      {
        home.activation.checkLinkTargets = lib.mkForce "";
      }
    ];
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        stateVersion = "23.11";
      };
      
      # Import the shared home-manager configuration as a module
      imports = [ ../shared/home-manager.nix ];

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Clean dock with your essential apps
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "/Users/rohit/Applications/Ghostty.app/"; }
        { path = "/Users/rohit/Applications/Zen.app/"; }
        { path = "/Applications/OrbStack.app/"; }
        { path = "/Users/rohit/Applications/Raycast.app/"; }
        { path = "/System/Applications/Music.app/"; }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
