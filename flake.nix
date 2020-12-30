{
  inputs =
    {
      nixpkgs.url          = "nixpkgs/master";
      nixpkgs-unstable.url = "nixpkgs/master";

      home-manager.url   = "github:rycee/home-manager/master";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";

      emacs-overlay.url  = "github:nix-community/emacs-overlay";
      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      inherit (lib) attrValues;
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs = mkPkgs nixpkgs [];
      uPkgs = mkPkgs nixpkgs-unstable [];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
    in {
      lib = lib.my;

      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ./.
            ./hosts/macbook-air/configuration.nix
          ];
        };
      };
    };
}
