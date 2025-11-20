{
  description = "NixOS configuration for lapland";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.897910.tar.gz";
  inputs.nom.url = "github:mbrock/nix-output-monitor";
  inputs.gptel = {
    url = "github:karthink/gptel";
    flake = false;
  };

  inputs.ghostty.url = "github:ghostty-org/ghostty";
  inputs.ghostty.follows = "nixpkgs";

  outputs = { self, nixpkgs, determinate, nom, gptel, ghostty, ... }: {
    nixosConfigurations.lapland = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom gptel ghostty; };
      modules = [
        determinate.nixosModules.default
        ./nixos-base.nix
        ./hardware-configuration.nix
        {
          networking.hostName = "lapland";
          # Reduce parallelism to avoid OOM on this VM
          nix.settings.max-jobs = 2;
          nix.settings.cores = 2;
        }
      ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nom gptel ghostty; };
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
