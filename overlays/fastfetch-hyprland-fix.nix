[
	(self: super: {
		fastfetch = with super; fastfetch.overrideAttrs {
			patches = [ ./fastfetch-hyprland-fix.patch ];
			cmakeFlags = fastfetch.cmakeFlags ++ [ (lib.cmakeBool "ENABLE_ELF" true) ];
			buildInputs = fastfetch.buildInputs ++ [ elfutils ];
		};
	})
]
