{
  description = "Emulators for PSP, PS2, PS3, and Xbox 360, GameCube/Wii, and MS-DOS on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true; # Required for Android SDK
        };

        xenia-canary = pkgs.stdenv.mkDerivation {
          pname = "xenia-canary";
          version = "2025-03-23"; 
          meta = {
            description = "Xenia Canary - Xbox 360 emulator";
            homepage = "https://xenia.jp/";
            platforms = [ "x86_64-linux" ];
          };
          src = pkgs.fetchurl {
            url = "https://github.com/xenia-canary/xenia-canary-releases/releases/latest/download/xenia_canary_linux.tar.gz";
            sha256 = "sha256-NYZeWbOyincP7jwexfgtjHiVna36vlvKl22XJ+d2G8k=";
          };
          nativeBuildInputs = [ pkgs.gnutar pkgs.makeWrapper ];
          unpackPhase = ''
            tar -xf $src
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp xenia_canary $out/bin/xenia-canary
            chmod +x $out/bin/xenia-canary
            wrapProgram $out/bin/xenia-canary --prefix LD_LIBRARY_PATH : ${
              pkgs.lib.makeLibraryPath [
                pkgs.gtk3
                pkgs.pango
                pkgs.cairo
                pkgs.glib
                pkgs.libGL
                pkgs.SDL2
                pkgs.pulseaudio
                pkgs.harfbuzz
                pkgs.atk
                pkgs.gdk-pixbuf
                pkgs.lz4
                pkgs.xorg.libX11
                pkgs.xorg.libxcb
                pkgs.xorg.libXfixes
                pkgs.at-spi2-core
              ]
            }
          '';
        };

        android-sdk = pkgs.androidenv.composeAndroidPackages {
          includeEmulator = true; # Enables the emulator
          platformVersions = [ "33" ]; # Android 13, adjust as needed
          abiVersions = [ "x86_64" ]; # For Intel/AMD CPUs, use "arm64-v8a" for ARM
          systemImageTypes = [ "google_apis_playstore" ]; # Google APIs image
          buildToolsVersions = [ "33.0.2" ]; # Required for AVD setup
          platformToolsVersion = "34.0.5"; # Includes adb, etc.
          cmdLineToolsVersion = "8.0"; # For avdmanager
        };

        android-canary = pkgs.stdenv.mkDerivation {
          pname = "android-canary";
          version = "2025-03-23";
          meta = {
            description = "Android Emulator with Pixel 7 AVD";
            platforms = [ "x86_64-linux" ];
          };
          dontUnpack = true;
          buildInputs = [ android-sdk.androidsdk pkgs.bash ];
          installPhase = ''
						 mkdir -p $out/bin
						 cat > $out/bin/android-emulator <<EOF
						 #!/bin/sh
						 export ANDROID_SDK_ROOT=${android-sdk.androidsdk}/libexec/android-sdk
						 export PATH=\$ANDROID_SDK_ROOT/emulator:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$PATH

						 if ! avdmanager list avd | grep -q "pixel_7"; then
							echo "Creating AVD 'pixel_7'..."
							avdmanager create avd --force --name pixel_7 --package "system-images;android-33;google_apis;x86_64" --device "pixel_7"
							if [ $? -ne 0 ]; then
								echo "Failed to create AVD, check logs"; exit 1;
							fi
						 fi

						 emulator -avd pixel_7 -no-snapshot-save -gpu host "\$@"
						 EOF
						 chmod +x $out/bin/android-emulator
          '';
        };
      in {
        apps = {
          # PSP emulator
          ppsspp = {
            type = "app";
            program = "${pkgs.ppsspp}/bin/ppsspp-qt";
          };

          # PS2 emulator
          pcsx2 = {
            type = "app";
            program = "${pkgs.pcsx2}/bin/pcsx2-qt";
          };

          # PS3 emulator
          rpcs3 = {
            type = "app";
            program = "${pkgs.rpcs3}/bin/rpcs3";
          };

          # Xbox 360 emulator
          xenia = {
            type = "app";
            program = "${xenia-canary}/bin/xenia-canary";
          };

          # Android emulator
          android = {
            type = "app";
            program = "${android-canary}/bin/android-emulator";
          };

          # Wii/Gamecube Emulator
          dolphin = {
            type = "app";
            program = "${pkgs.dolphin-emu}/bin/dolphin-emu";
          };

          # MS-DOS emulator
          dosbox = {
            type = "app";
            program = "${pkgs.dosbox}/bin/dosbox";
          };
        };
      });
}
