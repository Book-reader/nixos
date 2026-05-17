# Just whatever I think is critical for all base systems to have
{ ... }:
{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nixpkgs.config.allowUnfree = true;

	time.timeZone = "Pacific/Auckland";
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	programs.nix-ld.enable = true;

	# https://chrisdown.name/2026/03/24/zswap-vs-zram-when-to-use-what.html
	# zramSwap.enable = true;
	boot.zswap.enable = true;
}
