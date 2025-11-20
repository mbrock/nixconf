{
  description = "NixOS configuration for lapland";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nom.url = "github:mbrock/nix-output-monitor";
  inputs.gptel = {
    url = "github:karthink/gptel";
    flake = false;
  };

  outputs = { self, nixpkgs, determinate, nom, gptel, ... }: {
    nixosConfigurations.lapland = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom gptel; };
      modules = [
        determinate.nixosModules.default
        ./nixos-base.nix
        ./hardware-configuration.nix
        { networking.hostName = "lapland"; }
      ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom gptel; };
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