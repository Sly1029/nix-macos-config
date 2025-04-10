{
  description = "Rohit Work Nix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }: {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook-Pro-2
    darwinConfigurations."Rohits-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {

      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.rohitjayaram = import ./home.nix;
            backupFileExtension = "backup";
          };
          users.users.rohitjayaram = {
            name = "rohitjayaram";
            home = "/Users/rohitjayaram";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Rohits-MacBook-Pro-2".pkgs;
  };
}
