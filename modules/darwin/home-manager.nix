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

programs.zsh.enable = true;
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
    taps = ["withgraphite/tap" "nikitabobko/tap"];
    onActivation = { autoUpdate = true; cleanup = "zap"; };
    global.lockfiles = false;  # sets HOMEBREW_BUNDLE_NO_LOCK to avoid Nix store writes
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
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
