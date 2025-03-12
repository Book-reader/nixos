{
	description = "A simple NixOS flake";

	inputs = {
		# NixOS official package source, using the nixos-24.11 branch here
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

	};

	outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
	let
		unstable = import nixpkgs-unstable {};
	in {
		# Please replace my-nixos with your hostname
		nixosConfigurations = {
			NixOS-PC = nixpkgs.lib.nixosSystem {
				# oh noooo, my reproducibility has been ruined by external variables!!!!! whatever shall I do????
				system = builtins.currentSystem;
				specialArgs = { inherit inputs unstable; };
				modules = [
					# Import the previous configuration.nix we used,
					# so the old configuration file still takes effect
					./configuration.nix
					./clipboard-sync/flake.nix
				];
			};
		};
	};
}
