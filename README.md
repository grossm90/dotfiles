# dotfiles
My Arch config

## Home folder config

Each top-level folder except `system/` is a GNU stow package:

```bash
cd ~/dotfiles
stow hypr waybar kitty   # and so on
```

`pkglist.txt` is `pacman -Qqe`; `aurlist.txt` is `pacman -Qqm`.

## System config (`system/`)

A few files from `/etc` (greetd, its PAM rules, hyprlogin) are kept in
`system/etc/` as plain copies. They are not stowed: the login screen runs as
a separate user that cannot read the home folder, and files in `/etc` should
stay owned by root.

```bash
system/etc-sync.sh backup    # /etc -> repo, then review and commit
system/etc-sync.sh diff      # compare live files with the repo copies
system/etc-sync.sh restore   # repo -> /etc, asks before each file
```

`restore` keeps the previous version of each file beside it as `.bak`.
The list of tracked files is at the top of the script.
