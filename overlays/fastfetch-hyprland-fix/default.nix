(final: prev: {
	# fastfetch = with prev; fastfetch.overrideAttrs {
	# 	patches = [ ./fastfetch-hyprland-fix.patch ];
	# 	cmakeFlags = fastfetch.cmakeFlags ++ [ (lib.cmakeBool "ENABLE_ELF" true) ];
	# 	buildInputs = fastfetch.buildInputs ++ [ elfutils ];
	# };
})

