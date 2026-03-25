{ appimageTools, lib, fetchurl }:
let
	pname = "thorium";
	version = "138.0.7204.300";
	variant = "SSE4";
	name = "${pname}-${version}";

	src = fetchurl {
		url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_${variant}.AppImage";
		sha256 = "sha256-cr1yyiPYIh0JxLMlf0ZCt+Do0TYT6KvgYtM0ffknxVE=";
	};

	appimageContents = appimageTools.extract { inherit src pname version; };
in
appimageTools.wrapType2 {
	inherit src version pname;
	# extraPkgs = pkgs: [ pkgs.xorg.libxshmfence ];

	extraInstallCommands = ''
		install -m 444 -D ${appimageContents}/thorium-browser.desktop -t $out/share/applications
		cp -r ${appimageContents}/usr/share/icons $out/share
	'';

	meta = with lib; {
		description = "Thorium browser";
		homepage = "https://thorium.rocks";
		license = licenses.bsd3;
		platforms = [ "x86_64-linux" ];
		mainProgram = "thorium";
	};
}
