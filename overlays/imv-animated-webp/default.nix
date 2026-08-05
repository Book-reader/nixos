(final: prev: {
	imv = prev.imv.overrideAttrs (orig: {
		version = "5.0.1";
		src = final.fetchFromSourcehut {
			owner = "~exec64";
			repo = "imv";
			rev = "7dc0ddad88dcda466067028bea319216e40d4cbe";
			hash = "sha256-EXM8BLjOet+Kr73F4mAcvI9RDDUFTa8r1ZijWR8MEto=";
		};
		nativeBuildInputs = orig.nativeBuildInputs ++ [ final.wayland-scanner ];
		buildInputs = orig.buildInputs ++ [ final.lcms2 ];
	});
})

