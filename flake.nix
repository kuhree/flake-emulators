{
  description = "Emulators for PSP, PS2, PS3, PS4, GameCube/Wii, and MS-DOS on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        apps = {
          # PSP emulator
          ppsspp = {
            type = "app";
            program = "${pkgs.ppsspp}/bin/ppsspp";
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

          # PS4 emulator
          shadps4 = {
            type = "app";
            program = "${pkgs.shadps4}/bin/shadps4";
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
      }
    );
}
