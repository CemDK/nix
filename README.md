# Shokunix (職人 - nix)

My custom NixOS configuration with an optional installer.

## Building the ISO

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

The ISO will be in `./result/iso/`.

## Installation Process

1. **Boot from the ISO**
   - Flash the ISO to a USB drive using `dd` or similar tool
   - Boot from the USB drive

2. **Run the installer**
   - Open a terminal in the live environment
   - Run: `shokunix_installer`
   - The script will:
     - Let you choose which host to install (currently: `thinkpad`)
     - Partition the disk
     - Install NixOS with my configuration
