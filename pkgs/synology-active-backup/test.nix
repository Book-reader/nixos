let
	pkgs = import <nixpkgs> {};
in
# with pkgs;
# (import ./default.nix {inherit pkgs; inherit stdenv; inherit lib; fetchurl = builtins.fetchurl;}).env
{
	# abb = (pkgs.callPackage ./default.nix {}).abb;
	synosnap = (pkgs.linuxPackages.callPackage ./default.nix {}).synosnap;
}
