{ pkgs, username, ... }:
let
	fah_user = username;
	fah_dir = "/home/${fah_user}/folding@home/";
in {
	
	systemd.services.folding-at-home = {
		enable = true;
		description = "We have folding at home. folding at home:";
		wants = [ "network-online.target" ];
		after = [ "network-online.target" ];
		wantedBy = [ "network-online.target" ];
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.fahclient}/bin/fah-client";
			WorkingDirectory = fah_dir;
			Restart = "on-failure";
			RestartSec = 1;
			TimeoutStopSec = 10;
			User="${fah_user}";
			Group="users";
		};
	};
}
