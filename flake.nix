{
	description = "A simple NixOS flake";

	inputs = {
		# Why no workie :(
		# I have nix 2.27.0pre19700101_dirty
		# self.submodules = true;
		# NixOS official package source, using the nixos-24.11 branch here
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		# clipboard-sync.url = "path:clipboard-sync";
	};


	outputs = { self, nixpkgs, nixpkgs-unstable, clipboard-sync, ... }@inputs:
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
					# clipboard-sync.nixosModules.default
				];
			};
		};
	};
}
