{
  description = "NixOS configuration for lapland";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      determinate,
      ...
    }:
    {
      nixosConfigurations.lapland = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          determinate.nixosModules.default
          ./nixos-base.nix
          { networking.hostName = "lapland"; }

          # Integrate Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mbrock = import ./home.nix;
            home-manager.sharedModules = [
              agenix.homeManagerModules.default
            ];
          }

          # Integrate agenix
          agenix.nixosModules.default
        ];
      };

      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
    };
}
