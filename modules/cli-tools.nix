{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		kakoune
		git
		htop
		btop
		wget
		fastfetch
		fish
		nix-your-shell
		distrobox
		gtrash
		eza
		github-cli
		mlocate
		ffmpeg
		man-pages
		man-pages-posix
		pipx
		zip
		unzip
		bat
		tree
	];
}
