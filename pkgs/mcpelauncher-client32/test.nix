{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage_i686 ./default.nix {}
