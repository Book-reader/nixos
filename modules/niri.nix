{ pkgs, locale, ... }:
{
	security.polkit.enable = true;
	systemd.user.services.gnome-polkit = {
		enable = true;
		description = "polkit-gnome-authentication-agent-1";
		wants = [ "graphical-session.target" ];
		after = [ "graphical-session.target" ];
		wantedBy = [ "graphical-session.target" ];
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
			Restart = "on-failure";
			RestartSec = 1;
			TimeoutStopSec = 10;
		};
	};


	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};
	programs.niri.enable = true;
	environment.sessionVariables.NIXOS_OZONE_WL = "1";
	services.xserver.xkb.layout = "us";
	services.gnome.gnome-keyring.enable = true;

	# Enable sound.
	# rtkit changes audio scheduling and should fix audio crackling issues in some steam games
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		pulse.enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		# May not be needed
		# jack.enable = true;

		# Currently enabled by default.
		# media-session.enable = true;
	};

	services.libinput.enable = true;

	i18n.defaultLocale = locale;
	i18n.extraLocaleSettings = {
		LC_ADDRESS = locale;
		LC_IDENTIFICATION = locale;
		LC_MEASUREMENT = locale;
		LC_MONETARY = locale;
		LC_NAME = locale;
		LC_NUMERIC = locale;
		LC_PAPER = locale;
		LC_TELEPHONE = locale;
		LC_TIME = locale;
	};

}
