{ pkgs, username, ... }:
{
	users.users."${username}"= {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" "dialout" "mlocate" ];
		shell = pkgs.fish;
		# User specific packages
		# packages = with pkgs; [];
	};

	programs.fish = {
		enable = true;
		interactiveShellInit = ''
			nix-your-shell fish | source
		'';
	};
}

