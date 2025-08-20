{ stdenv, lib, buildFHSEnv, autoPatchelfHook, fetchurl
, dpkg
, unzip
, kernel
, kmod
, gcc
}:
let
	version = "3.0.0-4638";
	synosnap-version = "0.11.6";
	src = fetchurl {
		url = "https://global.synologydownload.com/download/Utility/ActiveBackupBusinessAgent/${version}/Linux/x86_64/Synology+Active+Backup+for+Business+Agent-${version}-x64-deb.zip";
		sha256 = "sha256-ZWZgAiznv3c0+kow2CCgs93c+rOzpR5oVi49icTMuBQ=";
	};


	synosnap = stdenv.mkDerivation {
		pname = "synosnap";
		inherit version;
		inherit src;
		dontUnpack = true;

		hardeningDisable = [ "pic" "format" ];
		nativeBuildInputs = [
			dpkg
			unzip
			autoPatchelfHook
			stdenv.cc.cc
		] ++ kernel.moduleBuildDependencies;


		installPhase = ''
			unzip $src
			./install.run --noexec --target .
			dpkg -x "synosnap-${synosnap-version}.deb" tmp
#
#			make -j(nproc) KERNELRELEASE=${kernel.modDirVersion}" "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
#    "INSTALL_MOD_PATH=$(out)"                                               # 5

			cd tmp/usr/src/synosnap-${synosnap-version}
			patchShebangs genconfig.sh
			# sed -i 's|SYSTEM_MAP_FILE="/lib/modules/\$.KERNEL_VERSION}/System.map"|SYSTEM_MAP_FILE="${kernel}/System.map"|' genconfig.sh || exit 1
			sed -i 's|SYSTEM_MAP_FILE="/lib/modules/\$.KERNEL_VERSION}/System.map"|SYSTEM_MAP_FILE="/nix/store/5p00xzf3i57m8zjmpbb0virsqav16rdv-linux-6.12.34/System.map"|' genconfig.sh || exit 1
			echo "cat \$SRC_DIR/kernel-config.h" >> genconfig.sh
			head -20 genconfig.sh
			echo '#define NULL (void*)0' | cat - bio_list.c > tmp && mv tmp bio_list.c

			sed -i 's|KDIR := /lib/modules/$(KERNELVERSION)/build|KDIR := ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build|' configure-tests/feature-tests/Makefile
			cat configure-tests/feature-tests/Makefile
			make KERNELRELEASE=${kernel.modDirVersion} KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build INSTALL_MOD_DIR=$out -j$(nproc)
		'';

		# sourceRoot = "tmp/usr/src/synosnap-${synosnap-version}";
	};


	abb = stdenv.mkDerivation rec {
		pname = "abb";
		inherit version;
		inherit src;
		
		nativeBuildInputs = [
			dpkg
			unzip
			autoPatchelfHook
			stdenv.cc.cc
		];

		buildInputs = []; # TODO

		runtimeDependencies = [ # TODO
		];

		dontUnpack = true;

		buildPhase = "";

		installPhase = ''
			unzip $src
			./install.run --noexec --target .
			dpkg -x "Synology Active Backup for Business Agent-${version}.deb" $out
			dpkg -x "synosnap-${synosnap-version}.deb" $out
			
			addAutoPatchelfSearchPath $out/opt/Synology/ActiveBackupforBusiness/lib
			# cp $out/opt/Synology/ActiveBackupforBusiness/lib/* $out/lib
		'';

		libraryPath = lib.makeLibraryPath [];

		meta = with lib; {
			description = "Synology Active Backup for Business Agent";
			homepage = "https://www.synology.com/";
			license = licenses.unfree;
			# maintainers = with lib.maintainers; [ ];
			platforms = [ "x86_64-linux" ];
		};
	};
in
{
	abb = abb;
	synosnap = synosnap;
}
