{ username, ... }:
{
	# TODO: make more generic (currently only works with laptop)
	services.syncthing = let
		devices = import /home/${username}/.config/syncthing/config.nix;
	in {
		enable = false; # true;
		user = username;
		key = "${/home/${username}/.config/syncthing/key.pem}";
		cert = "${/home/${username}/.config/syncthing/cert.pem}";
		settings = {
			devices = {
				"desktop" = { id = devices.desktop; };
			};
			folders = {
				"git" = {
					path = "/home/${username}/git";
					devices = [ "desktop" ];
				};
				"code" = {
					path = "/home/${username}/code";
					devices = [ "desktop" ];
				};
				"PrismLauncher" = {
					path = "/home/${username}/.local/share/PrismLauncher";
					devices = [ "desktop" ];
				};
				"Vintage Story" = {
					path = "/home/${username}/.var/app/at.vintagestory.VintageStory/config/VintagestoryData";
					# ignore = [ "clientsettings.json" ];
					devices = [ "desktop" ];
				};
				"Lutris" = {
					path = "/home/${username}/.var/app/net.lutris.Lutris/data";
					devices = [ "desktop" ];
				};
				"Lutris Games" = {
					path = "/home/${username}/Documents/games";
					devices = [ "desktop" ];
				};
			};
		};
	};


}
