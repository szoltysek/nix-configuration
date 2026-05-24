{
  description = "karol from terminal-index nixOS flake";
  # Computer that's running this flake: ThinkPad P53
  # CPU: i7-9850H
  # GPU: NVIDIA Quadro RTX 5000 Max-Q 16GB
  # RAM: 64GB

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Secure Boot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, ... }@inputs: {
    nixosConfigurations = {
      terminalindex = nixpkgs.lib.nixosSystem {  # Change terminalindex to your hostname, MUST MATCH!
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./hardware-configuration.nix
          ./configuration.nix
        ];
      };
    };
  };
}
