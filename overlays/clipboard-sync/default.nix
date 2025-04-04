(final: prev:
let
	clipboard-sync-flake = import (prev.fetchFromGitHub {
		owner = "dnut";
		repo = "clipboard-sync";
		rev = "943e49e0a9a16b54bbab3704e99b6cf6ad4ea19f";
		sha256 = "sha256-kTXsO+hskCfX36+Ez1fHu9SO54uUY2lofkrbMKE3Vrk=";
	});
in
{
	clipboard-sync = clipboard-sync-flake.packages.${builtins.currentSystem}.default {};
})
