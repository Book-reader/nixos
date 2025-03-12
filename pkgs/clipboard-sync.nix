{ pkgs ? import <nixpkgs> }:
pkgs.callPackage (pkgs.fetchFromGitHub {
	owner = "dnut";
	repo = "clipboard-sync";
	rev = "943e49e0a9a16b54bbab3704e99b6cf6ad4ea19f";
	sha256 = "sha256-kTXsO+hskCfX36+Ez1fHu9SO54uUY2lofkrbMKE3Vrk=";
}) {}
