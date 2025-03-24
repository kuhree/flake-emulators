# Emulators Flake for NixOS

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![NixOS](https://img.shields.io/badge/OS-NixOS-lightgrey.svg)
![Status](https://img.shields.io/badge/status-stable-green.svg)

## Overview

This Nix flake provides a collection of emulators for running games and applications from various platforms on NixOS, without polluting your system-wide configuration. It leverages Nix Flakes for isolated, reproducible environments, making it ideal for retro gaming enthusiasts and developers testing across platforms. Supported emulators include:

- **PPSSPP**: PlayStation Portable (PSP)
- **PCSX2**: PlayStation 2 (PS2)
- **RPCS3**: PlayStation 3 (PS3)
- **Xenia Canary**: Xbox 360
- **Android Emulator**: Android (Pixel 7 AVD with Play Store)
- **Dolphin**: Nintendo GameCube and Wii
- **DOSBox**: MS-DOS

Whether you’re reliving classics like *Midnight Club* or testing Android apps, this flake keeps everything neatly contained.

## Prerequisites

- **NixOS**: Any recent version (e.g., 23.11 or 24.05) with Flakes enabled.
- **Hardware**: 
  - Minimum: Intel i5/Ryzen 5, 8GB RAM, GPU with OpenGL/Vulkan (e.g., GTX 1050).
  - Recommended: Ryzen 7, 16GB+ RAM, RTX 3060 for PS3/Xbox 360/Android.
- **KVM**: Required for Android and Dolphin hardware acceleration (see Setup).
- **ROMs**: Legally dumped game files (e.g., `.iso`, `.exe`) from your own media.

## Installation

1. **Enable Flakes (if not already)**:
   - Edit `/etc/nixos/configuration.nix` or `~/.config/nix/nix.conf`:
     ```nix
     experimental-features = nix-command flakes
     ```
   - Rebuild: `sudo nixos-rebuild switch`.

2. **Clone the Flake**:
   ```bash
   git clone <repo_url>
   cd <project_name>
   ```

3. **Lock Dependencies**:
   - Cache inputs and verify hashes:
     ```bash
     nix flake lock
     ```

4. **Optional: Build All Apps**:
   - Test the build process:
     ```bash
     for app in ppsspp pcsx2 rpcs3 xenia android dolphin dosbox; do nix build .#$app; done
     ```

## Setup

### General Setup
- Place ROMs in a directory (e.g., `~/roms/`) for easy access.
- Connect a gamepad (Xbox/PS) via USB/Bluetooth—NixOS detects them automatically.

### Emulator-Specific Setup
- **PPSSPP**: No extra setup; load ROMs via GUI.
- **PCSX2**: 
  - Dump your PS2 BIOS (e.g., `scph10000.bin`) and place it in `~/.config/PCSX2/bios/`.
- **RPCS3**: 
  - Download PS3 firmware (`.PUP`) from [playstation.com](https://www.playstation.com/en-us/support/hardware/ps3/system-software/).
  - Install it via RPCS3 GUI (`File > Install Firmware`).
- **Xenia**: No BIOS needed; ensure Wine works (test with `nix-shell -p wineWowPackages.stable --run "wine --version"`).
- **Android Emulator**: 
  - Enable KVM in your NixOS config:
    ```nix
    boot.kernelModules = [ "kvm-amd" ]; # or "kvm-intel"
    users.users.<your-user>.extraGroups = [ "kvm" ];
    ```
    Rebuild: `sudo nixos-rebuild switch`.
  - AVD (`pixel_7`) auto-creates on first run.
- **Dolphin**: Enable KVM (as above) for best performance; no BIOS required.
- **DOSBox**: Optional config file at `~/.dosbox/dosbox.conf`.

## Usage

Run emulators with `nix run .#<app-name>` from the `<project_name>` directory. Examples:

- **PPSSPP**: `nix run .#ppsspp`, then `File > Load` to select a `.iso`.
- **PCSX2**: `nix run .#pcsx2`, configure BIOS, load `.iso` via GUI.
- **RPCS3**: `nix run .#rpcs3`, install firmware, add games via GUI.
- **Xenia**: `nix run .#xenia /path/to/game.iso` (follow [Xenia docs](https://xenia.jp/docs)).
- **Android**: `nix run .#android` (first run creates AVD; use `adb` for apps).
- **Dolphin**: `nix run .#dolphin`, load `.iso` or `.wbfs` via GUI.
- **DOSBox**: `nix run .#dosbox -c "mount c /path/to/game" -c "c:" -c "game.exe"`.

For all emulators in one shell:
```bash
nix shell .#ppsspp .#pcsx2 .#rpcs3 .#xenia .#android .#dolphin .#dosbox
```

## Configuration

Adjust settings via each emulator’s GUI or CLI:
- **PPSSPP**: Graphics/controls in `Settings`.
- **PCSX2**: `Config > Video` (Vulkan recommended), `Config > Controllers`.
- **RPCS3**: `Config > GPU` (Vulkan), `Config > Pads`.
- **Xenia**: Edit `xenia.config.toml` in game directory (see [Xenia wiki](https://xenia.jp/wiki)).
- **Android**: Pass flags (e.g., `nix run .#android -- -no-audio`).
- **Dolphin**: `Options > Graphics Settings` (Vulkan/OpenGL).
- **DOSBox**: Edit `~/.dosbox/dosbox.conf` or pass CLI flags.

Refer to official docs for details:
- [PPSSPP](https://ppsspp.org/docs/)
- [PCSX2](https://wiki.pcsx2.net/)
- [RPCS3](https://rpcs3.net/wiki)
- [Xenia](https://xenia.jp/wiki)
- [Android](https://developer.android.com/studio/run/emulator)
- [Dolphin](https://wiki.dolphin-emu.org/)
- [DOSBox](https://dosbox.com/wiki/)

## How to Run

From `<project_name>/`:
- Single emulator: `nix run .#<app-name>` (e.g., `nix run .#dolphin`).
- With arguments: Append flags (e.g., `nix run .#dosbox /path/to/game.exe`).
- Verify: If an emulator fails, check FAQ or run `nix flake check`.

## How to Make Changes

1. **Edit `flake.nix`**:
   - Add emulators: Copy an `apps` entry (e.g., `snes9x = { type = "app"; program = "${pkgs.snes9x}/bin/snes9x"; };`).
   - Update Xenia SHA256: Re-run `nix-prefetch-url --unpack <url>` if the release changes.
   - Adjust Android version: Modify `platformVersions` (e.g., `["30"]`).

2. **Test Changes**:
   - `nix flake lock` to update dependencies.
   - `nix run .#<app-name>` to test.

3. **Commit**:
   - `git add flake.nix && git commit -m "Added SNES9x emulator"`.

## FAQ

### Common Errors/Issues
- **"Hash mismatch" on Xenia**:
  - Cause: New Xenia release updated the ZIP.
  - Fix: Re-run `nix-prefetch-url --unpack https://github.com/xenia-canary/xenia-canary/releases/latest/download/xenia_canary.zip`, update `sha256` in `flake.nix`, then `nix flake lock`.
- **"Failed to create AVD" on Android**:
  - Cause: KVM not enabled or SDK issue.
  - Fix: Verify KVM (`lsmod | grep kvm`), check `~/.android/avd/pixel_7.avd/` logs, ensure `android-sdk` builds (`nix build .#android`).
- **"PCSX2 won’t start"**:
  - Cause: Missing BIOS.
  - Fix: Place BIOS in `~/.config/PCSX2/bios/`.
- **"RPCS3 black screen"**:
  - Cause: No firmware.
  - Fix: Install `.PUP` via `File > Install Firmware`.

### Common Questions
- **Can I use a stable Nixpkgs version?**:
  - Yes, change `nixpkgs.url` to `"github:NixOS/nixpkgs/nixos-23.11"` for stability.
- **How do I add a new emulator?**:
  - Add to `apps` (e.g., `citra = { type = "app"; program = "${pkgs.citra}/bin/citra-qt"; };`), then `nix flake lock`.
- **Why Android Play Store?**:
  - Included for app testing; switch to `"google_apis"` in `systemImageTypes` for a lighter image.
- **Performance slow?**:
  - Check GPU drivers (`nvidia-driver` or Mesa), enable KVM, upscale conservatively (e.g., 720p for PS3).

## Contributing

Contributions welcome! Fork the repo, make changes, and submit a PR. See “How to Make Changes” for guidance.

## License

MIT License - see [LICENSE](LICENSE) file.

## Acknowledgments

- NixOS community for Flakes and emulator packages.
- Emulator developers: PPSSPP, PCSX2, RPCS3, Xenia, Android, Dolphin, DOSBox teams.

