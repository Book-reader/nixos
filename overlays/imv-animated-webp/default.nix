(final: prev: {
	imv = prev.imv.overrideAttrs (orig: {
		version = "5.0.2-git";
		src = fetchFromSourcehut {
			owner = "~exec64";
			repo = "imv";
			commit = "7dc0ddad88dcda466067028bea319216e40d4cbe";
			hash = "";
		};
	});
})

