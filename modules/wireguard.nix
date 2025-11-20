{ ... }:
{
	# TODO: make more generic (currently cannot work for anything other than the nuc)
	networking.wireguard = {
			enable = true;
			interfaces = {
					wg0 = {
							ips = [ "10.8.0.7/24" ];
							listenPort = 51820;
							# mtu = 1360;
							privateKeyFile = "/etc/wireguard/private.key";
							peers = [{
									publicKey = "WRvoZtk5jopY/15cCKJF1QzaI+MZhpcYzH0SBoUfK3o=";
									presharedKeyFile = "/etc/wireguard/preshared.key";
									allowedIPs = [ "10.8.0.0/24" ];
									endpoint = (import /etc/wireguard/server-ip.nix {}).ip;
									persistentKeepalive = 25;
							}];
					};
			};
	};
}
