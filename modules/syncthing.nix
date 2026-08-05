{ username, hostname, lib, ... }:
{
	# TODO: make more generic (currently only works with laptop)
	services.syncthing = let
		devices = {
			"NixOS-Desktop" = { id = "GVQJETJ-KDG5VKE-QHKR3BF-DVK3W3B-7IHY2H5-5FQJQ5M-3XHTVTD-V7ID2QH"; };
			"NixOS-PC" = { id = "NEOUUFV-YPSUXYB-TD42M2O-5H37NNI-E2NYCQF-IE4XX6Q-Z4DO3BM-67TVUAF"; };
		};
		otherDevices = lib.filterAttrs (k: v: k != hostname) devices;
		otherDeviceNames = lib.attrNames otherDevices;

		folder = /*{ */name/*, ... }@extra*/: extra: {
			path = "/home/${username}/${name}";
			devices = otherDeviceNames;
			versioning = {
				type = "staggered";
				params = {
					maxAge = lib.toString (3 * 60 * 60 * 24);
					# cleanoutDays = "10";
				};
			};
			rescanIntervalS = (6 * 60 * 60); # do a full rescan every 6 hours
			cleanupIntervalS = (1 * 60 * 60);
		} // extra;
	in {
		enable = true;
		user = username;
		group = "users";
		# key = "${/home/${username}/.config/syncthing/key.pem}";
		# cert = "${/home/${username}/.config/syncthing/cert.pem}";
		dataDir = "/home/${username}";
		configDir = "/home/${username}/.config/syncthing";
		openDefaultPorts = true;
		overrideFolders = true;
		overrideDevices = true;
		settings = {
			devices = otherDevices;
			options = {
				minHomeDiskFree = {
					unit = "%";
					value = 10;
				};
			};
			folders = {
				# "git" = folder "git" {};
				# "code" = folder "code" {};
				"PrismLauncher" = folder ".local/share/PrismLauncher" {};
				"Vintage Story" = folder ".var/app/at.vintagestory.VintageStory/config/VintagestoryData" {
					ignorePatterns = [ "clientsettings.json" ];
				};
				"Lutris" = folder ".var/app/net.lutris.Lutris/data" {};
				"Lutris Games" = folder "Documents/games" {};
			};
		};
	};
	systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
