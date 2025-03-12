{
	description = "A simple NixOS flake";

	inputs = {
		# Why no workie :(
		# I have nix 2.27.0pre19700101_dirty
		# self.submodules = true;

		# I use this the non-optimal way out of spite
		nixpkgs.url = "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
		nixpkgs-unstable.url = "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
		# clipboard-sync.url = "path:clipboard-sync";
	};


	outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
	let
		unstable = import nixpkgs-unstable {};
	in {
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
