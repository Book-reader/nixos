# home-manager is completely incomprehensible, I'll probably try to figure it out later maybe
# why do I need to set `home.username` and `home.homeDirectory` when I'm already fucking doing `home-manager.users.${username} = THIS FUCKING FILE`???
# it already knows my username, and it can just use the nixos config to get my home directory
# stupid
{ home-manager, username, ... }:
{
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
	home-manager.users.${username} = { pkgs, ... }: {
		home.stateVersion = "25.11";
	};
}
