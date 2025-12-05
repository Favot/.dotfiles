# Stow Configuration

This repository uses GNU Stow to manage dotfiles and configuration files.

## Setup

### Initial Setup

1. Run the stow script to create symlinks:
   ```bash
   ./stow.sh
   ```

### Managing .config Directory

The `stow-config.sh` script manages all configuration files in the `.config` directory. It will:

- Create symlinks from `~/.config/*` to `~/.dotfiles/.config/*`
- Backup any existing files/directories before replacing them
- Skip items that are already correctly linked

### Adding New Config Files

1. Add your config file/directory to `~/.dotfiles/.config/`
2. Run `./stow.sh` to create the symlink

### Removing Config Files

To remove a symlink (but keep the file in dotfiles):
```bash
cd ~/.dotfiles
stow -d ~/.dotfiles -t ~ -D .config
# Then manually remove the specific item if needed
```

### Unstowing Everything

To remove all symlinks:
```bash
cd ~/.dotfiles
stow -d ~/.dotfiles -t ~ -D .config
```

## Currently Managed Configs

- `gh/` - GitHub CLI configuration
- `i3/` - i3 window manager config
- `neofetch/` - Neofetch configuration
- `nix/` - Nix flake configuration
- `nvim/` - Neovim configuration
- `ohmyposh/` - Oh My Posh theme
- `polybar/` - Polybar configuration
- `starship.toml` - Starship prompt configuration

## Notes

- Files/directories in `~/.config` that are NOT in `~/.dotfiles/.config/` will remain untouched
- The dotfiles `.config` directory is the source of truth
- Always commit changes to dotfiles before running stow

