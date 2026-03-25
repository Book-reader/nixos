{ stdenv, lib, buildFHSEnv, autoPatchelfHook, fetchurl
, kernel
, kernelModuleMakeFlags
, kmod
, dpkg
, unzip
, gcc
, bash
}:
let
	version = "3.1.0-4967";
	synosnap-version = "0.11.6";
	src = fetchurl {
		url = "https://global.synologydownload.com/download/Utility/ActiveBackupBusinessAgent/${version}/Linux/x86_64/Synology+Active+Backup+for+Business+Agent-${version}-x64-deb.zip";
		sha256 = "sha256-ObvjGv/zlbIiqD233fWwNHI5sAIRQBhdMngAnnz4mEI=";
	};


	synosnap = stdenv.mkDerivation rec {
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

		makeFlags = kernelModuleMakeFlags ++ [
			"KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
			"KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
			"INSTALL_MOD_PATH=$out"                                                 # 5
		];

		prePatch = ''
			unzip $src
			./install.run --noexec --target .
			dpkg -x "synosnap-${synosnap-version}.deb" tmp
			cd tmp/usr/src/synosnap-${synosnap-version}/
			substituteInPlace ./genconfig.sh \
				--replace-fail "/bin/bash" "${bash.outPath}/bin/bash" \
				--replace-fail "/lib/modules/\''${KERNEL_VERSION}/System.map" "${kernel}/System.map"
				# --replace-fail "&>/dev/null" "" \
				# --replace-fail "ls -1 -q \$FEATURE_TEST_FILES | xargs -P \"\$MAX_THREADS\" -d\"\\n\" -I {} bash -c 'run_one_test {}'" "run_one_test configure-tests/feature-tests/bdev_open_by_path.c; exit"
			substituteInPlace ./Makefile ./configure-tests/feature-tests/Makefile \
				--replace-fail "KDIR := /lib/modules/\$(KERNELVERSION)/build" "KDIR := ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
				--replace-fail "KERNELVERSION ?= \$(shell uname -r)" "KERNELVERSION ?= ${kernel.modDirVersion}"
			substituteInPlace ./configure-tests/feature-tests/Makefile \
				--replace-fail "\$(MAKE) -C \$(KDIR) M=\$(BUILDDIR) src=\$(PWD) modules" "\$(MAKE) -C \$(KDIR) M=\$(PWD) \$(OBJ)"
			substituteInPlace ./configure-tests/feature-tests/bdev_open_by_path.c ./bdev_state_handler.c ./ioctl_handlers.c ./tracer.c \
				--replace-fail "bdev_open_by_path" "bdev_file_open_by_path" \
				--replace-warn "bdev_handle" "file"
			# cat genconfig.sh
		'';

		buildPhase = ''
			echo "${lib.strings.concatStringsSep " " makeFlags}"
			make ${lib.strings.concatStringsSep " " makeFlags}
			# ./genconfig.sh ${kernel.modDirVersion} -j1
		'';

#		installPhase = ''
#			unzip $src
#			./install.run --noexec --target .
#			dpkg -x "synosnap-${synosnap-version}.deb" tmp
##
##			make -j(nproc) KERNELRELEASE=${kernel.modDirVersion}" "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
##    "INSTALL_MOD_PATH=$(out)"                                               # 5
#
#			cd tmp/usr/src/synosnap-${synosnap-version}
#			patchShebangs genconfig.sh
#			# sed -i 's|SYSTEM_MAP_FILE="/lib/modules/\$.KERNEL_VERSION}/System.map"|SYSTEM_MAP_FILE="${kernel}/System.map"|' genconfig.sh || exit 1
#			sed -i 's|SYSTEM_MAP_FILE="/lib/modules/\$.KERNEL_VERSION}/System.map"|SYSTEM_MAP_FILE="/nix/store/5p00xzf3i57m8zjmpbb0virsqav16rdv-linux-6.12.34/System.map"|' genconfig.sh || exit 1
#			echo "cat \$SRC_DIR/kernel-config.h" >> genconfig.sh
#			head -20 genconfig.sh
#			echo '#define NULL (void*)0' | cat - bio_list.c > tmp && mv tmp bio_list.c
#
#			sed -i 's|KDIR := /lib/modules/$(KERNELVERSION)/build|KDIR := ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build|' configure-tests/feature-tests/Makefile
#			cat configure-tests/feature-tests/Makefile
#			make KERNELRELEASE=${kernel.modDirVersion} KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build INSTALL_MOD_DIR=$out -j$(nproc)
#		'';
#
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
