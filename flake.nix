{
	description = "My NixOS flake";

	inputs = {
		/*nixpkgs = {
			url = "github:NixOS/nixpkgs/nixos-25.05";
			#overlays = import ./overlays;
			#config.allowUnfree = true;
		};*/
		nixpkgs/*-unstable*/.url = "github:NixOS/nixpkgs/nixos-unstable";
		/*nur = {
			url = "github:nix-community/NUR";
			inputs.nixpkgs.follows = "nixpkgs";
		};*/

		/*lix = {
			url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
			flake = false;
		};

		lix-module = {
			url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.lix.follows = "lix";
		};*/
	};


	outputs = { self, nixpkgs, nur, /*nixpkgs-unstable,*/ /*lix, lix-module,*/ ... }@inputs:
	let
		/*unstable = import nixpkgs-unstable {
			config.allowUnfree = true;
		};*/
		/*pkgs = import nixpkgs {
			overlays = import ./overlays;
			# overlays = [ lix-module.overlays.default ] ++ import ./overlays;
			config.allowUnfree = true;
		};*/
		pkgsOverride = (inputs: {
			nixpkgs = {
				overlays = import ./overlays;
				config.allowUnfree = true;
			};
		});

		username = "user";
		locale = "en_NZ.UTF-8";
	in {
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# I don't like flakes enough to allow this to be pure
				system = builtins.currentSystem;
				specialArgs = let hostname = "NixOS-PC"; in { inherit inputs /*nixpkgs*/ username hostname locale/*unstable*/; };
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
					./modules/syncthing.nix
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
					./modules/syncthing.nix
				];
			};

		};
	};
}
