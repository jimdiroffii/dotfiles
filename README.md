# dotfiles

Configuration files for common shells, applications and services such as bash, zsh and tmux.

## ZSH Configuration (zsh4humans)

Instructions for setting up [zsh4humans](https://github.com/romkatv/zsh4humans/tree/master).

1) Ensure `zsh` is installed, of course.

```bash
sudo apt install zsh
```

2) Copy the following files to the home directory.

- `.zshenv`
- `.zshrc`
- `.p10k.zsh`

~~*Note: Use `.p10k.zsh-server` for minimal config that excludes glyphs, rename to `p10k.zsh`*~~

*Note 2: `.p10k.zsh` was reconfigured to use a minimal config, no glyphs, by default*

3) Install the [MesloLGS Nerd Font patched for Powerlevel10k](https://github.com/romkatv/powerlevel10k/blob/master/font.md).

*The MesloLGS font files were added to this repository in `./fonts`.*

4) And setup the SSH configuration (copy `.ssh/config`), if SSH push/copy of zsh files is wanted.

