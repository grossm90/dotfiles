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

## Rebuilding from scratch

`bootstrap.sh` turns a fresh Arch install into this setup: packages, config
links, login-screen files, services, and the teaching repos. It does not
install Arch itself and does not restore personal files.

### 1. Install Arch

Use `archinstall` from the Arch ISO. To match this setup, choose:

- **Bootloader:** GRUB
- **Kernel:** `linux-lts`
- **Network:** NetworkManager
- **Profile:** minimal (the script installs the desktop)
- **A user with sudo rights**
- **Additional packages:** `git`

### 2. Run the script

Reboot into the new system, log in at the text console, and connect to the
network (`nmtui` for WiFi). Then:

```bash
git clone https://github.com/grossm90/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --dry-run    # shows every action, changes nothing
./bootstrap.sh
```

It asks for your password (sudo), and for confirmation before installing
packages and before each file it puts in `/etc`. Building the AUR packages
is the slow part. When it finishes, reboot; the login screen should appear.

The steps, in order:

| Step | What it does |
|---|---|
| `packages` | Installs everything in `pkglist.txt` that the official repos carry |
| `aur` | Builds `paru` if needed, then installs `aurlist.txt` |
| `stow` | Links every config folder into the home folder. A real file in the way (such as the default `~/.bashrc`) is moved to `~/.dotfiles-backup-<date>/` first |
| `system` | Runs `system/etc-sync.sh restore` for the greetd and hyprlogin files |
| `services` | Enables the system and user services; they start at the next boot |
| `repos` | Clones `teaching-scripts` and `cte-courses` into `~/git` and links the teaching scripts into `~/.local/bin` |

If a step fails, the summary names it. Fix the cause and run just that
step, for example `./bootstrap.sh --only aur`. Every step can be repeated
safely. `./bootstrap.sh --help` lists the options.

### 3. After the script

These need you, or live outside this repo:

- **GitHub:** `gh auth login`. If `repos` could not clone a private repo,
  run `./bootstrap.sh --only repos` afterwards. Create or restore an SSH key
  if you push over SSH.
- **Files:** sign in to the Nextcloud client and let it sync.
- **Neovim:** open it once and wait for the plugins to install. Then use
  `:Mason` to install `pico8-ls` and any formatters.
- **Node:** `nvm install --lts`.
- **PICO-8:** not a package. Reinstall it from your Lexaloffle account;
  carts live in `~/.lexaloffle`, which is not backed up here.
- **Browser:** sign in to Zen's sync to get bookmarks and extensions back.
- **GTK theme:** pick Catppuccin in `nwg-look`.

Firmware and the battery charge thresholds live in the laptop itself and
survive a reinstall.

### Keeping it current

The script can only rebuild what the repo knows about. After installing or
removing software:

```bash
cd ~/dotfiles
pacman -Qqe > pkglist.txt
pacman -Qqm > aurlist.txt
system/etc-sync.sh backup
git add -A && git commit -m "update package lists" && git push
```

Service names are listed at the top of `bootstrap.sh`; add a line there
when you enable a new one.
