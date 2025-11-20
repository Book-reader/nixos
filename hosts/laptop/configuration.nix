# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, nixpkgs, /*unstable,*/ ... }:
let
	locale = "en_NZ.UTF-8";
in
{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
		];

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	programs.nix-ld.enable = true;

	zramSwap.enable = true;
	swapDevices = [ { device = "/swap/swapfile"; } ];
	fileSystems = {
		"/".options = [ "compress=zstd:3" ];
		"/home".options = [ "compress=zstd:3" ];
		"/nix".options = [ "compress=zstd:3" "noatime" ];
		"/swap".options = [ "noatime" ];
	};

	documentation = {
			enable = true;
			man.enable = true;
			# Apparently not needed because I use fish
			# man.generateCaches = true;
			nixos.includeAllModules = true;
			dev.enable = true;
	};

	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
			# intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
		];
	};
	environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";# Optionally, set the environment variable

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	# boot.kernelParams = [
	# 	"intel_pstate=disable"
	# ];

	networking.hostName = "NixOS-PC"; # Define your hostname.
	# Pick only one of the below networking options.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.
	networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.
	networking.wireguard.enable = true;

	# A hack to fix mullvads local network sharing not working across subnets
	# TODO: figure out why it breaks each time I resume from suspend and mullvad reconnects
	# ip route add 192.168.0.0/16 via 192.168.2.1 dev wlp0s20f3 onlink table main
	networking.interfaces.wlp0s20f3.ipv4.routes = [
		{
			address = "192.168.0.0";
			via = "192.168.2.1";
			prefixLength = 16;
			options = {
				table = "main";
				onlink = "onlink"; # Another hack to get onlink working
			};
		}
	];


	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

	# Set your time zone.
	time.timeZone = "Pacific/Auckland";

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Select internationalisation properties.
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
	# i18n.inputMethod = {
	# 	enable = true;
	# 	type = "ibus";
	# 	ibus.engines = with pkgs.ibus-engines; [
	# 		m17n
	# 	];
	# };
	# console = {
	# 	font = "Lat2-Terminus16";
	# 	keyMap = "us";
	# 	useXkbConfig = true; # use xkb.options in tty.
	# };

	programs.starship.enable = true;
	programs.steam.enable = true;

	# Enable the X11 windowing system.
	# services.xserver.enable = true;
	programs.hyprland = {
		enable = true;
		withUWSM = true;
	};
	xdg.portal = {
		enable = true;
		# xdgOpenUsePortal = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};
	programs.niri.enable = true;
	environment.sessionVariables.NIXOS_OZONE_WL = "1";


	# Configure keymap in X11
	services.xserver.xkb.layout = "us";
	# services.xserver.xkb.options = "eurosign:e,caps:escape";
	#
	users.users.user = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" "dialout" "mlocate" ];
		shell = pkgs.fish;
		# User specific packages
		# packages = with pkgs; [];
	};

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


	programs.fish = {
		enable = true;
		interactiveShellInit = ''
			nix-your-shell fish | source
		'';
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		# Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		alacritty
		waybar
		# starship
		# Hypr*
		hyprlock
		hypridle
		hyprpaper
		# End Hypr*
		tofi
		rofi
		nemo
		nemo-fileroller
		file-roller
		polkit_gnome
		imv
		zenity # For running desktop files exported from distrobox --root
		mullvad-vpn
		# (mullvad-vpn.overrideAttrs(prev: {buildInputs = prev.buildInputs ++ [libva];})) # for hardware acceleration
		brightnessctl
		pavucontrol
		pamixer
		ffmpegthumbnailer
		# trashy # trash-cli replacement. unmaintained :(
		# another trash-cli replacement
		wl-clipboard
		networkmanagerapplet
		
		prismlauncher
		
		gparted
		xorg.xhost
		auto-cpufreq
		papirus-icon-theme
		grim
		slurp
		rustup
		libnotify
		swaynotificationcenter
		mpv
		wf-recorder
		# clipboard-sync
		# (pkgs.callPackage ./pkgs/clipboard-sync.nix {})
		(pkgs.callPackage ../../pkgs/betterdiscord-installer.nix {})
		vscode.fhs
		# (import ./nix/default.nix).default
		syncthing
		wireguard-tools
		xwayland-satellite
		python3
		wineWowPackages.waylandFull
		file
		# (pkgs.callPackage ../../pkgs/synology-active-backup/default.nix {})
		(pkgs.callPackage ../../pkgs/waterfox.nix {})
		qutebrowser
		emacs
		/*unstable.*/tea # for authenticating with forgejo servers

		bitwarden-cli # both for bitwarden integration in qutebrowser
		keyutils

		wakatime-cli

		# nur.repos.ataraxiasjel.waydroid-script

		gdu
		imagemagick # I like magick
	];

	security.polkit.enable = true;

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	services.gnome.gnome-keyring.enable = true;

	virtualisation = {
		containers.enable = true;
		# waydroid.enable = true;
		podman = {
			enable = true;
			# Create a `docker` alias for podman, to use it as a drop-in replacement
			dockerCompat = true;
			# Required for containers under podman-compose to be able to talk to each other.
			defaultNetwork.settings.dns_enabled = true;
		};
	};
	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	services.clamav = {
		daemon.enable = false;
		scanner.enable = true;
		updater.enable = true;
		fangfrisch.enable = true;
	};

	services.mullvad-vpn.enable = true;
	services.auto-cpufreq = {
		enable = true;
		settings = {
			battery = {
				enable_thresholds = true;
				start_threshold = 70;
				stop_threshold = 80;
			};
			charger = {
				energy_perf_bias = "performance";
				# scaling_max_freq = 4800000;
			};
		};
	};
	services.flatpak.enable = true;
	services.dbus.enable = true;
	services.gvfs.enable = true;
	# services.clipboard-sync.enable = true;

	# Enable CUPS to print documents.
	services.printing = {
		enable = true;
		drivers = with pkgs; [ gutenprint cnijfilter2 ];
	};

	services.syncthing = let
		devices = import /home/user/.config/syncthing/config.nix;
	in {
		enable = false; # true;
		user = "user";
		key = "${/home/user/.config/syncthing/key.pem}";
		cert = "${/home/user/.config/syncthing/cert.pem}";
		settings = {
			devices = {
				"desktop" = { id = devices.desktop; };
			};
			folders = {
				"git" = {
					path = "/home/user/git";
					devices = [ "desktop" ];
				};
				"code" = {
					path = "/home/user/code";
					devices = [ "desktop" ];
				};
				"PrismLauncher" = {
					path = "/home/user/.local/share/PrismLauncher";
					devices = [ "desktop" ];
				};
				"Vintage Story" = {
					path = "/home/user/.var/app/at.vintagestory.VintageStory/config/VintagestoryData";
					# ignore = [ "clientsettings.json" ];
					devices = [ "desktop" ];
				};
				"Lutris" = {
					path = "/home/user/.var/app/net.lutris.Lutris/data";
					devices = [ "desktop" ];
				};
				"Lutris Games" = {
					path = "/home/user/Documents/games";
					devices = [ "desktop" ];
				};
			};
		};
	};


	# Enable sound.
	# hardware.pulseaudio.enable = true;
	# OR
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

	# Enable touchpad support (enabled default in most desktopManager).
	services.libinput.enable = true;

	# Open ports in the firewall.
	networking.firewall.allowedTCPPorts = [ 25565 53317 ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "24.11"; # Did you read the comment?

}

