{
  description = "NixOS configuration for lapland";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
  inputs.nom = {
    url = "github:mbrock/nix-output-monitor";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, determinate, nom, ... }: {
    nixosConfigurations.lapland = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom; };
      modules = [
        determinate.nixosModules.default
        ./nixos-base.nix
        ./hardware-configuration.nix
        { networking.hostName = "lapland"; }
      ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom; };
      modules = [
        determinate.nixosModules.default
        ./nixos-base.nix
        ./hardware-configuration-nixos.nix
        { networking.hostName = "nixos"; }
      ];
    };

    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
  };
}