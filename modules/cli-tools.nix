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
		# Fix build failure: https://github.com/NixOS/nixpkgs/issues/522307
		(pipx.overridePythonAttrs {doCheck = false;})
		zip
		unzip
		bat
		tree
		fd
		ripgrep
	];
}
