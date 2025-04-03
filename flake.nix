{
	description = "My NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		# clipboard-sync.url = "path:clipboard-sync";
	};


	outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
	let
		unstable = import nixpkgs-unstable {
			config.allowUnfree = true;
		};
		pkgs = import nixpkgs {
			overlays = import ./overlays/fastfetch-hyprland-fix.nix;
			config.allowUnfree = true;
		};
	in {
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# I don't like flakes enough to allow this to be pure
				system = builtins.currentSystem;
				specialArgs = { inherit inputs unstable pkgs nixpkgs; };
				modules = [
					#(import ./overlays)
					# Import the previous configuration.nix we used,
					# so the old configuration file still takes effect
					./configuration.nix

					# clipboard-sync.nixosModules.default
				];
			};
		};
	};
}
