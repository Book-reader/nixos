{ pkgs, lib, ... }:
{
	nixpkgs.overlays = [
		(import ./fastfetch-hyprland-fix.nix)
	];
}
