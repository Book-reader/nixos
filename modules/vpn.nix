{ pkgs, ... }:
{
	services.mullvad-vpn = {
		enable = true;
		gui.enable = true;
		# package = pkgs.mullvad-vpn;
	};
}
