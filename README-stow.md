# Stow Configuration

This repository uses GNU Stow to manage dotfiles and configuration files.

## Setup

### Initial Setup

1. Run stow to create symlinks:
   ```bash
   cd ~/.dotfiles
   stow -t ~/.config .config
   ```

### Managing .config Directory

The command above creates symlinks from `~/.config/*` to `~/.dotfiles/.config/*`.

### Adding New Config Files

1. Add your config file/directory to `~/.dotfiles/.config/`
2. Run `stow -t ~/.config .config` to create the symlink

### Removing Config Files

To remove a symlink (but keep the file in dotfiles):
```bash
cd ~/.dotfiles
stow -t ~/.config -D .config
# Then manually remove the specific item if needed
```

### Unstowing Everything

To remove all symlinks:
```bash
cd ~/.dotfiles
stow -t ~/.config -D .config
```

## Currently Managed Configs

- `gh/` - GitHub CLI configuration
- `ghostty/` - Ghostty terminal configuration
- `i3/` - i3 window manager config
- `neofetch/` - Neofetch configuration
- `nix/` - Nix flake configuration
- `nvim/` - Neovim configuration
- `ohmyposh/` - Oh My Posh theme
- `polybar/` - Polybar configuration
- `starship.toml` - Starship prompt configuration
- `zed/` - Zed editor configuration

## Notes

- Files/directories in `~/.config` that are NOT in `~/.dotfiles/.config/` will remain untouched
- The dotfiles `.config` directory is the source of truth
- Always commit changes to dotfiles before running stow

