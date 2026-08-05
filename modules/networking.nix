{ hostname, ... }:
let
	iface = if hostname == "NixOS-PC" then "wlp0s20f3" else "wlp10s0";
in {
	networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.
	networking.wireguard.enable = true;
	networking.hostName = hostname;


	# A hack to fix mullvads local network sharing not working across subnets
	# TODO: figure out why it breaks each time I resume from suspend and mullvad reconnects
	# ip route add 192.168.0.0/16 via 192.168.2.1 dev wlp0s20f3 onlink table main
	# networking.interfaces.${iface}.ipv4.routes = [
	# 	{
	# 		address = "192.168.0.0";
	# 		via = "192.168.2.1";
	# 		prefixLength = 16;
	# 		options = {
	# 			table = "main";
	# 			onlink = "onlink"; # Another hack to get onlink working
	# 		};
	# 	}
	# ];

	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

}
