{
	description = "My NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
	};


	outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
	let
		unstable = import nixpkgs-unstable {
			config.allowUnfree = true;
		};
		pkgs = import nixpkgs {
			overlays = import ./overlays;
			config.allowUnfree = true;
		};
	in {
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# I don't like flakes enough to allow this to be pure
				system = builtins.currentSystem;
				specialArgs = { inherit inputs unstable pkgs nixpkgs; };
				modules = [
					./hosts/laptop/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
					./modules/gui-programs.nix
					./modules/hyprland.nix
				];
			};
			NixOS-NUC = nixpkgs.lib.nixosSystem {
				system = builtins.currentSystem;
				specialArgs = { inherit inputs unstable pkgs nixpkgs; };
				modules = [
					./hosts/nuc/configuration.nix
					./modules/user.nix
					./modules/cli-tools.nix
				];
			};
		};
	};
}
