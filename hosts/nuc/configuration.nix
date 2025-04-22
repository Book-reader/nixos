# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
      hostName = "NixOS-NUC"; # Define your hostname.
      /*interfaces.eno1 = {
          ipv4.addresses = [{
              address = "192.168.20.3";
              prefixLength = 24;
          }];
      };
      defaultGateway = {
          address = "192.168.20.255";
          interface = "eno1";
      };
      useDHCP = true;
      enableIPv6 = false;*/
      interfaces = {};
  };

  fileSystems =
  let
    ip = "192.168.20.2";
    automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,rw,defaults,_netdev";
    credentials = "credentials=/etc/smb-secrets";
    uid = "uid=1000,gid=100";
    options = "${automount_opts},${credentials},${uid}";
  in
  {
      "/nas/home" = {
          device = "//${ip}/home";
          fsType = "cifs";
          options = [options];
      };
      "/nas/docker" = {
          device = "//${ip}/docker";
          fsType = "cifs";
          options = ["${options},nobrl"];
      };
  };
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "nz";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICH5PqjKgnfryfMZaFgDv8aUjC9fF6y7wAQXLtLKIy1U user"
    ];
  };

  users.users.immich = {
      isNormalUser = true;
      uid = 1001;
      home = "/immich";
      shell = "/sbin/nologin";
  };
  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    cifs-utils
  ];

  virtualisation = {
      containers.enable = true;
      docker.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
      enable = true;
      settings = {
          # PasswordAuthentication = false;
          # KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
      };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.wireguard = {
      enable = true;
      interfaces = {
          wg0 = {
              ips = [ "10.8.0.7/24" ];
              # address = [ "10.8.0.7/24" ];
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

  networking.wg-quick = {};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
