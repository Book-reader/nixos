{
	description = "My NixOS flake";

	inputs = {
		nixpkgs = {
			url = "github:NixOS/nixpkgs/nixos-25.05";
			#overlays = import ./overlays;
			#config.allowUnfree = true;
		};
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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


	outputs = { self, nixpkgs, nixpkgs-unstable, /*lix, lix-module,*/ ... }@inputs:
	let
		unstable = import nixpkgs-unstable {
			config.allowUnfree = true;
		};
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
	in {
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# I don't like flakes enough to allow this to be pure
				system = builtins.currentSystem;
				specialArgs = { inherit inputs nixpkgs unstable; };
				modules = [
					pkgsOverride
					./hosts/laptop/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/gui-programs.nix
					./modules/hyprland.nix
				];
			};
			NixOS-NUC = nixpkgs.lib.nixosSystem {
				system = builtins.currentSystem;
				specialArgs = { inherit inputs nixpkgs; };
				modules = [
					pkgsOverride
					./hosts/nuc/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
				];
			};
			NixOS-Desktop = nixpkgs.lib.nixosSystem {
				system = builtins.currentSystem;
				specialArgs = { inherit inputs nixpkgs; };
				modules = [
					pkgsOverride
					./hosts/desktop/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/gui-programs.nix
					./modules/hyprland.nix
				];
			};

		};
	};
}
