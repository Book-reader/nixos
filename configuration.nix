# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, nixpkgs, unstable, ... }:
let
	locale = "en_NZ.UTF-8";
	fastfetchPatched = pkgs.fastfetch.overrideAttrs (final: prev: {
		patches = [ ./pkgs/fastfetch-hyprland.patch ];
		cmakeFlags = prev.cmakeFlags ++ [ (lib.cmakeBool "ENABLE_ELF" true) ];
		buildInputs = prev.buildInputs ++ [ pkgs.elfutils ];
	});
	pkgs = import nixpkgs {};
in
{

	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
			# ./pkgs/clipboard-sync.nix
		];

/*	nixpkgs.overlays = let
		clipboard-sync-flake = import (pkgs.fetchFromGitHub {
			owner = "dnut";
			repo = "clipboard-sync";
			rev = "943e49e0a9a16b54bbab3704e99b6cf6ad4ea19f";
			sha256 = "sha256-kTXsO+hskCfX36+Ez1fHu9SO54uUY2lofkrbMKE3Vrk=";
		});
	in [
		(final: prev: {
    			clipboard-sync = clipboard-sync-flake.packages.${builtins.currentSystem}.default {};
		})
	];
	clipboard-sync = {
		url = "github:dnut/clipboard-sync";
	};*/

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	zramSwap.enable = true;
	swapDevices = [ { device = "/swap/swapfile"; } ];
	fileSystems = {
		"/".options = [ "compress=zstd:1" ];
		"/home".options = [ "compress=zstd:1" ];
		"/nix".options = [ "compress=zstd:1" "noatime" ];
		"/swap".options = [ "noatime" ];
	};

	documentation = {
    		enable = true;
    		man.enable = true;
    		man.generateCaches = true;
    		nixos.includeAllModules = true;
    		dev.enable = true;
	};

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "NixOS-PC"; # Define your hostname.
	# Pick only one of the below networking options.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.
	networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.
	networking.wireguard.enable = true;

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
	environment.sessionVariables.NIXOS_OZONE_WL = "1";

	# Enable the GNOME Desktop Environment.
	# services.xserver.displayManager.gdm.enable = true;
	# services.xserver.desktopManager.gnome.enable = true;


	# Configure keymap in X11
	services.xserver.xkb.layout = "us";
	# services.xserver.xkb.options = "eurosign:e,caps:escape";
	#
	# Define a user account. Don't forget to set a password with ‘passwd’.
	# users.users.alice = {
	#	 isNormalUser = true;
	#	 extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	#	 packages = with pkgs; [
	#		 tree
	#	 ];
	# };
	users.users.user = {
		isNormalUser = true;
		extraGroups = [ "networkmanager" "wheel" "dialout" "mlocate" ];
		shell = pkgs.fish;
		# User specific packages
		# packages = with pkgs; [];
	};

	systemd.user.services.polkit-gnome-authentication-agent-1 = {
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

	# programs.firefox.enable = true;
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		kakoune # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		alacritty
		waybar
		git
		htop
		btop
		wget
		fastfetchPatched
		fish
		nix-your-shell
		# starship
		# Hypr*
		hyprlock
		hypridle
		hyprpaper
		# End Hypr*
		tofi
		rofi-wayland
		distrobox
		nemo
		nemo-fileroller
		file-roller
		polkit_gnome
		imv
		zenity # For running desktop files exported from distrobox --root
		mullvad-vpn
		brightnessctl
		pavucontrol
		pamixer
		ffmpegthumbnailer
		# trashy # trash-cli replacement. unmaintained :(
		gtrash # another trash-cli replacement
		wl-clipboard
		networkmanagerapplet
		eza
		prismlauncher
		github-cli
		gparted
		xorg.xhost
		auto-cpufreq
		papirus-icon-theme
		mlocate
		grim
		slurp
		rustup
		libnotify
		swaynotificationcenter
		mpv
		wf-recorder
		ffmpeg
		man-pages
		man-pages-posix
		pipx
		(pkgs.callPackage ./pkgs/clipboard-sync.nix {})
		(pkgs.callPackage ./pkgs/betterdiscord-installer.nix {})
		zip
		unzip
		# (import ./nix/default.nix).default
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	services.gnome.gnome-keyring.enable = true;

	virtualisation.containers.enable = true;
	virtualisation = {
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

	services.mullvad-vpn.enable = true;
	services.auto-cpufreq.enable = true;
	services.flatpak.enable = true;
	services.dbus.enable = true;
	# services.clipboard-sync.enable = true;

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound.
	# hardware.pulseaudio.enable = true;
	# OR
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
	# networking.firewall.allowedTCPPorts = [ ... ];
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

