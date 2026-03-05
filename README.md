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

## Homelab Deployment

### Deploy to homelab

```bash
rsync -avz --delete \
    --exclude '.git' \
    --filter=':- .gitignore' \
    /home/cem/.config/nix/ \
    cemdk@192.168.178.66:/home/cemdk/.config/nix/

nix shell nixpkgs#nixos-rebuild --command nixos-rebuild switch \
    --flake .#wyse-5070 \
    --target-host cemdk@192.168.178.66 \
    --sudo
```

The `--filter=':- .gitignore'` flag makes rsync respect `.gitignore` files in each directory, so container state data (databases, caches) on the target machine is left untouched while config files (traefik YAML, homer dashboard) are synced.

### Backup Strategy

Container data is split into two categories:

- **Config files** (traefik YAML, homer dashboard, CSS) — tracked in Git, synced via rsync
- **State data** (navidrome DB, audiobookshelf DB) — gitignored, backed up with Restic on the target machine

The backup module is at `modules/backup.nix`. It uses `services.restic.backups` to run daily backups with container stop/start hooks to prevent SQLite corruption.

### Setting Up Backups

1. Create the restic password file on the target machine:
   ```bash
   ssh cemdk@192.168.178.66
   echo "your-secure-password" | sudo tee /etc/restic-password
   sudo chmod 600 /etc/restic-password
   ```

2. Make sure the backup destination exists (default: `/mnt/backup/restic/containers`):
   ```bash
   sudo mkdir -p /mnt/backup/restic/containers
   ```

3. Uncomment the backup import in `hosts/nixos/homelab/lab-phy-01/configuration.nix`:
   ```nix
   imports = [
     ../common.nix
     ./hardware-configuration.nix
     ../../../../modules/backup.nix
   ];
   ```

4. Deploy. Restic will auto-initialize the repository on first run.

### Checking Backup Status

```bash
# SSH into the target machine, then:

# List all snapshots
sudo restic -r /mnt/backup/restic/containers -p /etc/restic-password snapshots

# Check the last backup ran successfully
sudo systemctl status restic-backups-containers.service

# See the timer schedule
sudo systemctl list-timers restic-backups-containers

# Run a backup manually
sudo systemctl start restic-backups-containers.service
```

### Restoring from Backup

```bash
# SSH into the target machine, then:

# List available snapshots
sudo restic -r /mnt/backup/restic/containers -p /etc/restic-password snapshots

# Stop the containers first
sudo systemctl stop podman-navidrome.service
sudo systemctl stop podman-audiobookshelf.service

# Restore the latest snapshot to original paths
sudo restic -r /mnt/backup/restic/containers -p /etc/restic-password restore latest --target /

# Or restore a specific snapshot (use ID from snapshots list)
sudo restic -r /mnt/backup/restic/containers -p /etc/restic-password restore abc123 --target /

# Or restore only a specific service
sudo restic -r /mnt/backup/restic/containers -p /etc/restic-password restore latest \
    --target / \
    --include "/home/cemdk/.config/nix/modules/containers/navidrome/data"

# Restart the containers
sudo systemctl start podman-navidrome.service
sudo systemctl start podman-audiobookshelf.service
```

Restic restores files to their original absolute paths when using `--target /`. The `--include` flag lets you restore a single service without affecting others.


## Secret Management

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using age encryption. Keys are derived from SSH ed25519 host keys on each machine.

### Secret Structure

```
secrets/
├── global.yaml                        # Shared across all machines
├── homelab/
│   └── lab-phy-01/secrets.yaml        # Only for lab-phy-01
└── linux/
    └── cem-ryzen/secrets.yaml         # Only for Cem-Ryzen
```

**Global secrets** — credentials shared across machines:
- Cloudflare API tokens, DNS provider credentials
- VPN/WireGuard keys, shared SSH deploy keys
- Email SMTP credentials, notification service API keys

**Per-machine secrets** — credentials only one machine needs:
- Container-specific passwords (database credentials, app API keys)
- Samba/service user passwords, Traefik dashboard auth
- Backup encryption passphrases, disk encryption recovery keys

### Key Groups (`.sops.yaml`)

Each secrets path has a key group defining which machines can decrypt it. `cem_ryzen` is included in every group since it's the workstation used to edit secrets.

```yaml
keys:
  - &cem_ryzen age1...
  - &lab_phy_01 age1...

creation_rules:
  # Per-machine (matched first — order matters)
  - path_regex: secrets/homelab/lab-phy-01/.*\.(yaml|json|env|ini)$
    key_groups:
      - age:
          - *cem_ryzen
          - *lab_phy_01

  - path_regex: secrets/linux/cem-ryzen/.*\.(yaml|json|env|ini)$
    key_groups:
      - age:
          - *cem_ryzen

  # Global (fallback)
  - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
    key_groups:
      - age:
          - *cem_ryzen
          - *lab_phy_01
```

### Using Secrets in NixOS

Sops configuration lives in each machine's `configuration.nix`. Use `defaultSopsFile` for the primary secrets file and override with `sopsFile` per-secret when mixing global and per-machine secrets:

```nix
{ config, self, user, ... }:
{
  sops = {
    defaultSopsFile = "${self}/secrets/global.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      # From global file (uses defaultSopsFile)
      "cloudflare/token".owner = config.users.users.${user}.name;

      # From per-machine file (explicit override)
      "db/password" = {
        sopsFile = "${self}/secrets/homelab/lab-phy-01/secrets.yaml";
        owner = config.users.users.${user}.name;
      };
    };
  };
}
```

<details>
<summary><b>Initial Setup</b></summary>

If your SSH key is password-protected or you are using an rsa key, read [sops-nix github](https://github.com/Mic92/sops-nix?tab=readme-ov-file#usage-example)

Generate an age key from your ssh key (id_ed25519):
```bash
mkdir -p ~/.config/sops/age && \
    nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt" && \
    chmod g-rwx ~/.config/sops/age/keys.txt && \
    chmod o-rwx ~/.config/sops/age/keys.txt
```

Get the corresponding public key:
```bash
nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
# Output: age1...
```

Get the public age key for other machines:
```bash
# Remote host:
nix-shell -p ssh-to-age --run 'ssh-keyscan <host> | ssh-to-age'
# Local host:
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

Add the public key to `.sops.yaml` as a new anchor in `keys`, then reference it in the appropriate `creation_rules` key groups.

</details>

<details>
<summary><b>Adding a New Machine</b></summary>

1. Get the machine's age public key (see Initial Setup above)
2. Add it to `.sops.yaml` `keys` section with an anchor (e.g. `&new_machine`)
3. Add a per-machine creation rule **before** the global fallback rule:
   ```yaml
   - path_regex: secrets/path/to/machine/.*\.(yaml|json|env|ini)$
     key_groups:
       - age:
           - *cem_ryzen
           - *new_machine
   ```
4. Add `*new_machine` to the global rule if the machine needs global secrets
5. Re-encrypt existing secrets the machine needs:
   ```bash
   nix-shell -p sops --run "sops updatekeys secrets/global.yaml"
   ```
6. Create per-machine secrets directory and file:
   ```bash
   mkdir -p secrets/path/to/machine
   nix-shell -p sops --run "sops secrets/path/to/machine/secrets.yaml"
   ```

</details>

<details>
<summary><b>Adding Secrets</b></summary>

Global secret (all machines can decrypt):
```bash
nix-shell -p sops --run "sops secrets/global.yaml"
```

Per-machine secret:
```bash
nix-shell -p sops --run "sops secrets/homelab/lab-phy-01/secrets.yaml"
```

Then reference the secret in the machine's `configuration.nix` `sops.secrets` attrset.

</details>

## TODOs

- [ ] Add Mission Center to pkgs
- [ ] refactor steam stuff
- [ ] Auto-login + passwordless sudo on a server with exposed services (physical access = root)
- [ ] TLS without cert resolver — all services get self-signed certs (likely fine for .nixos.local)
- [ ] credential.helper = "store" saves git tokens in plaintext on disk
- [ ] backup.nix hardcodes paths instead of using flake self or a module argument
