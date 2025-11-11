{
  description = "NixOS configuration for lapland";

  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs = { self, nixpkgs, determinate, ... }: {
    nixosConfigurations.lapland = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        determinate.nixosModules.default
        ./nixos-base.nix
        { networking.hostName = "lapland"; }
      ];
    };

    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
  };
}