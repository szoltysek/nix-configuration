{
  description = "karol from terminal-index nixOS flake";
  # Computer that's running this flake: ThinkPad P53
  # CPU: i7-9850H
  # GPU: NVIDIA Quadro RTX 5000 Max-Q 16GB
  # RAM: 64GB

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, nur, ... }@inputs: {
    nixosConfigurations = {
      terminalindex = nixpkgs.lib.nixosSystem {  # Change terminalindex to your hostname, MUST MATCH!
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          nur.modules.nixos.default
          ./hardware-configuration.nix
          ./configuration.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ti = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
