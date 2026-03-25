{
	description = "My NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		/*tagstudio = {
			url = "github:TagStudioDev/TagStudio";
			inputs.nixpkgs.follows = "nixpkgs";
		};*/

/*		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};*/
	};


	outputs = { self, nixpkgs, nur, home-manager, ... }@inputs:
	let
		pkgsOverride = (inputs: {
			nixpkgs = {
				overlays = import ./overlays;
				config.allowUnfree = true;
			};
		});

		username = "user";
		locale = "en_NZ.UTF-8";

/*		home-manager-config = {
			home-manager = {
				useGlobalPkgs = true;
				useUserPackages = true;
				users.${username} = ./modules/home-manager.nix;
			};
		};*/
	in {
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# I don't like flakes enough to allow this to be pure
				system = builtins.currentSystem;
				specialArgs = let hostname = "NixOS-PC"; in { inherit inputs username hostname locale home-manager; };
				modules = [
					pkgsOverride
					# nur.modules.nixos.default
					./hosts/laptop/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/gui-programs.nix
					./modules/niri.nix
					./modules/folding-at-home.nix
					./modules/base.nix
					./modules/networking.nix
					./modules/cpufreq.nix
					# ./modules/syncthing.nix
					./modules/vpn.nix
					./modules/ime.nix
					# home-manager.nixosModules.home-manager
					# home-manager-config
				];
			};
			NixOS-NUC = nixpkgs.lib.nixosSystem {
				system = builtins.currentSystem;
				specialArgs = { inherit inputs /*nixpkgs*/ username; };
				modules = [
					pkgsOverride
					./hosts/nuc/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/folding-at-home.nix
				];
			};
			NixOS-Desktop = nixpkgs.lib.nixosSystem {
				system = builtins.currentSystem;
				specialArgs = let hostname = "NixOS-Desktop"; in { inherit inputs /*nixpkgs*/ username hostname locale; };
				modules = [
					pkgsOverride
					./hosts/desktop/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/gui-programs.nix
					./modules/hyprland.nix
					./modules/folding-at-home.nix
					./modules/base.nix
					./modules/networking.nix
					# ./modules/syncthing.nix
					./modules/vpn.nix
				];
			};

		};
	};
}
