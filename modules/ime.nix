{ pkgs, ... }:
{
	i18n.inputMethod = {
		enable = true;
		type = "ibus";
		ibus = {
			waylandFrontend = true;
			engines = with pkgs.ibus-engines; [
				m17n
				libpinyin
			];
		};
	};
}
