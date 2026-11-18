#!/usr/bin/env bash
#
# Rebuilds this laptop's setup on a fresh Arch install.
#
# Run it as your normal user (not root), from a clone of this repo, on a
# system that already boots, has a network connection, and has sudo set up.
# It does NOT partition disks, install Arch itself, or restore personal
# files. See "Rebuilding from scratch" in README.md for the full sequence.
#
#   ./bootstrap.sh                 run every step
#   ./bootstrap.sh --dry-run       show what would happen, change nothing
#   ./bootstrap.sh --list          list the steps
#   ./bootstrap.sh --only stow     run only the named steps (comma-separated)
#   ./bootstrap.sh --skip repos    run everything except the named steps
#   ./bootstrap.sh --noconfirm     don't ask before installing packages
#
# Every step is safe to run again. If something fails part way, fix the
# cause and rerun; finished work is skipped.

set -uo pipefail

# ----------------------------------------------------------------------------
# Settings
# ----------------------------------------------------------------------------

REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

STEPS=(packages aur stow system services repos)

# Folders in this repo that are not stow packages.
NOT_STOW_PACKAGES=(system)

# In aurlist.txt but not installed from it: paru is built by this script,
# and paru-debug is a by-product of that build.
AUR_SKIP=(paru paru-debug)

# Enabled but not started: everything takes effect at the reboot the script
# asks for at the end. (Starting greetd now would take over the screen.)
SYSTEM_UNITS=(
    NetworkManager.service
    greetd.service
    bluetooth.service
    ntpd.service
    fstrim.timer
    reflector.timer
    system76.service
    system76-firmware-daemon.service
    com.system76.PowerDaemon.service
)

USER_UNITS=(
    hyprpolkitagent.service
    gnome-keyring-daemon.socket
    pipewire-pulse.socket
    wireplumber.service
)

# Other repos to clone into ~/git. An entry of the form "name:package" also
# stows that package from the repo into the home folder.
GITHUB_USER="grossm90"
EXTRA_REPOS=(
    "teaching-scripts:scripts"
    "cte-courses"
)
EXTRA_REPOS_DIR="$HOME/git"

# Only for testing against stand-in files; leave unset in normal use.
OS_RELEASE="${BOOTSTRAP_OS_RELEASE:-/etc/os-release}"

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------

DRY_RUN=0
NOCONFIRM=0
ONLY=""
SKIP=""
WARNINGS=()
FAILED_STEPS=()
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    \033[33mwarning:\033[0m %s\n' "$*"; WARNINGS+=("$*"); }

# Runs a command that changes something; in a dry run, only prints it.
run() {
    if (( DRY_RUN )); then
        printf '    [dry run] %s\n' "$*"
        return 0
    fi
    "$@"
}

in_list() {
    local needle="$1"; shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

wanted() {
    local step="$1"
    if [[ -n "$ONLY" ]]; then
        [[ ",$ONLY," == *",$step,"* ]]
    else
        [[ ",$SKIP," != *",$step,"* ]]
    fi
}

# Prints the non-empty, non-comment lines of a list file.
read_list() {
    grep -vE '^\s*(#|$)' "$1"
}

# ----------------------------------------------------------------------------
# Checks before anything is changed
# ----------------------------------------------------------------------------

preflight() {
    say "Checking the system"

    if (( EUID == 0 )); then
        echo "Run this as your normal user, not as root. It uses sudo where needed." >&2
        return 1
    fi

    if ! grep -qE '^ID=arch$' "$OS_RELEASE" 2>/dev/null; then
        echo "This does not look like Arch Linux ($OS_RELEASE). Stopping." >&2
        return 1
    fi

    local tool
    for tool in sudo pacman git; do
        if ! command -v "$tool" >/dev/null; then
            echo "Missing '$tool'. Install it first: pacman -S sudo git (as root)." >&2
            return 1
        fi
    done

    for tool in pkglist.txt aurlist.txt; do
        if [[ ! -r "$REPO/$tool" ]]; then
            echo "Cannot read $REPO/$tool." >&2
            return 1
        fi
    done

    if ! (( DRY_RUN )) && ! curl -fsI --max-time 10 https://archlinux.org >/dev/null 2>&1; then
        echo "No network connection (could not reach archlinux.org). Connect, then rerun." >&2
        return 1
    fi

    info "repo: $REPO"
    info "user: $USER, home: $HOME"
    return 0
}

# ----------------------------------------------------------------------------
# Step: packages (official repositories)
# ----------------------------------------------------------------------------

step_packages() {
    say "Installing packages from the official repositories"

    run sudo pacman -Sy || return 1

    # pkglist.txt holds everything installed by hand, AUR packages included.
    # Split it into what the official repos have and what they don't.
    local available official=() missing=() pkg
    available="$(pacman -Slq | sort -u)"

    while read -r pkg; do
        if grep -qxF "$pkg" "$REPO/aurlist.txt"; then
            continue
        elif grep -qxF "$pkg" <<<"$available"; then
            official+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done < <(read_list "$REPO/pkglist.txt")

    for pkg in "${missing[@]}"; do
        warn "'$pkg' is in pkglist.txt but not in the official repos or aurlist.txt (renamed or removed?)"
    done

    if (( ${#official[@]} == 0 )); then
        warn "no official packages found to install"
        return 1
    fi

    info "${#official[@]} packages"
    local args=(-Su --needed)
    (( NOCONFIRM )) && args+=(--noconfirm)
    run sudo pacman "${args[@]}" "${official[@]}"
}

# ----------------------------------------------------------------------------
# Step: aur (paru itself, then the AUR packages)
# ----------------------------------------------------------------------------

install_paru() {
    command -v paru >/dev/null && return 0

    say "Building paru (the AUR helper)"
    if (( DRY_RUN )); then
        info "[dry run] clone https://aur.archlinux.org/paru.git and run makepkg -si"
        return 0
    fi

    local build
    build="$(mktemp -d)" || return 1
    git clone --depth 1 https://aur.archlinux.org/paru.git "$build/paru" || return 1
    local args=(-si)
    (( NOCONFIRM )) && args+=(--noconfirm)
    ( cd "$build/paru" && makepkg "${args[@]}" ) || return 1
    rm -rf "$build"
    command -v paru >/dev/null
}

step_aur() {
    install_paru || { warn "could not build paru; AUR packages were not installed"; return 1; }

    say "Installing AUR packages"

    local pkgs=() pkg
    while read -r pkg; do
        in_list "$pkg" "${AUR_SKIP[@]}" && continue
        pkgs+=("$pkg")
    done < <(read_list "$REPO/aurlist.txt")

    (( ${#pkgs[@]} )) || { info "nothing to install"; return 0; }
    info "${#pkgs[@]} packages: ${pkgs[*]}"

    local args=(-S --needed)
    (( NOCONFIRM )) && args+=(--noconfirm)

    # All at once first. If that fails, go one at a time so a single broken
    # package doesn't block the rest.
    if run paru "${args[@]}" "${pkgs[@]}"; then
        return 0
    fi

    info "installing one at a time after a failure"
    local failed=0
    for pkg in "${pkgs[@]}"; do
        if ! run paru "${args[@]}" "$pkg"; then
            warn "AUR package '$pkg' failed to install"
            failed=1
        fi
    done
    return "$failed"
}

# ----------------------------------------------------------------------------
# Step: stow (link the config into the home folder)
# ----------------------------------------------------------------------------

# Moves aside any real file that sits where a link needs to go, such as the
# default ~/.bashrc on a new system. Files that already are the repo's copy
# (through an existing link) are left alone.
clear_the_way() {
    local stow_dir="$1" pkg="$2" rel src target dir

    while IFS= read -r -d '' rel; do
        src="$stow_dir/$pkg/$rel"
        target="$HOME/$rel"

        # A dead link higher up the path (left behind when a repo is moved)
        # blocks stow just as a file would.
        dir="$rel"
        while [[ "$dir" == */* ]]; do
            dir="${dir%/*}"
            if [[ -L "$HOME/$dir" && ! -e "$HOME/$dir" ]]; then
                info "removing broken link: ~/$dir"
                run rm "$HOME/$dir"
            fi
        done

        [[ -e "$target" || -L "$target" ]] || continue
        [[ "$target" -ef "$src" ]] && continue

        if [[ -L "$target" && ! -e "$target" ]]; then
            info "removing broken link: ~/$rel"
            run rm "$target"
        elif [[ ! -L "$target" ]]; then
            info "moving existing file aside: ~/$rel"
            run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            run mv "$target" "$BACKUP_DIR/$rel"
        fi
    done < <(cd "$stow_dir/$pkg" && find . -type f -printf '%P\0')
}

stow_package() {
    local stow_dir="$1" pkg="$2"
    clear_the_way "$stow_dir" "$pkg"
    if ! run stow --restow --dir="$stow_dir" --target="$HOME" "$pkg"; then
        warn "stow reported a problem with '$pkg' (from $stow_dir)"
        return 1
    fi
}

step_stow() {
    say "Linking config into the home folder"

    if ! command -v stow >/dev/null && ! (( DRY_RUN )); then
        warn "stow is not installed; run the packages step first"
        return 1
    fi

    local dir pkg failed=0
    for dir in "$REPO"/*/; do
        pkg="$(basename "$dir")"
        in_list "$pkg" "${NOT_STOW_PACKAGES[@]}" && continue
        info "$pkg"
        stow_package "$REPO" "$pkg" || failed=1
    done

    [[ -d "$BACKUP_DIR" ]] && info "files moved aside are in $BACKUP_DIR"
    return "$failed"
}

# ----------------------------------------------------------------------------
# Step: system (files in /etc)
# ----------------------------------------------------------------------------

step_system() {
    say "Restoring system config files in /etc"
    info "you will be shown each change and asked before it is installed"

    if (( DRY_RUN )); then
        "$REPO/system/etc-sync.sh" diff
        return 0
    fi
    "$REPO/system/etc-sync.sh" restore
}

# ----------------------------------------------------------------------------
# Step: services
# ----------------------------------------------------------------------------

step_services() {
    say "Enabling services (they start at the next boot)"

    local unit failed=0
    for unit in "${SYSTEM_UNITS[@]}"; do
        if systemctl list-unit-files "$unit" --no-legend 2>/dev/null | grep -q .; then
            run sudo systemctl enable "$unit" || { warn "could not enable $unit"; failed=1; }
        else
            warn "service '$unit' does not exist (is its package installed?)"
        fi
    done

    for unit in "${USER_UNITS[@]}"; do
        if systemctl --user list-unit-files "$unit" --no-legend 2>/dev/null | grep -q .; then
            run systemctl --user enable "$unit" || { warn "could not enable user unit $unit"; failed=1; }
        else
            warn "user service '$unit' does not exist (is its package installed?)"
        fi
    done

    return "$failed"
}

# ----------------------------------------------------------------------------
# Step: repos (other repos this laptop needs)
# ----------------------------------------------------------------------------

clone_repo() {
    local name="$1" dest="$2"

    if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
        run gh repo clone "$GITHUB_USER/$name" "$dest"
    else
        # Works without signing in only if the repo is public.
        GIT_TERMINAL_PROMPT=0 run git clone "https://github.com/$GITHUB_USER/$name.git" "$dest"
    fi
}

step_repos() {
    say "Cloning other repos into $EXTRA_REPOS_DIR"

    run mkdir -p "$EXTRA_REPOS_DIR"

    local entry name pkg dest failed=0
    for entry in "${EXTRA_REPOS[@]}"; do
        name="${entry%%:*}"
        pkg=""
        [[ "$entry" == *:* ]] && pkg="${entry#*:}"
        dest="$EXTRA_REPOS_DIR/$name"

        if [[ -d "$dest/.git" ]]; then
            info "$name: already cloned"
        elif ! clone_repo "$name" "$dest"; then
            warn "could not clone $name. Sign in with 'gh auth login', then run: ./bootstrap.sh --only repos"
            failed=1
            continue
        fi

        if [[ -n "$pkg" ]]; then
            if [[ -d "$dest/$pkg" ]]; then
                info "$name: linking '$pkg' into the home folder"
                stow_package "$dest" "$pkg" || failed=1
            elif ! (( DRY_RUN )); then
                warn "$name has no '$pkg' folder to stow"
            fi
        fi
    done

    return "$failed"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

usage() {
    sed -n '3,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (( $# )); do
    case "$1" in
        --dry-run)   DRY_RUN=1 ;;
        --noconfirm) NOCONFIRM=1 ;;
        --only)      ONLY="${2:-}"; shift ;;
        --skip)      SKIP="${2:-}"; shift ;;
        --list)      printf '%s\n' "${STEPS[@]}"; exit 0 ;;
        -h|--help)   usage; exit 0 ;;
        *)           echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# Catch a mistyped step name before doing any work.
for name in ${ONLY//,/ } ${SKIP//,/ }; do
    if ! in_list "$name" "${STEPS[@]}"; then
        echo "unknown step: $name (steps: ${STEPS[*]})" >&2
        exit 2
    fi
done

preflight || exit 1

for step in "${STEPS[@]}"; do
    wanted "$step" || continue
    if ! "step_$step"; then
        FAILED_STEPS+=("$step")
    fi
done

say "Summary"
if (( ${#WARNINGS[@]} )); then
    info "warnings:"
    for w in "${WARNINGS[@]}"; do
        info "  - $w"
    done
fi

if (( ${#FAILED_STEPS[@]} )); then
    info "steps with problems: ${FAILED_STEPS[*]}"
    info "fix the cause, then rerun: ./bootstrap.sh --only $(IFS=,; echo "${FAILED_STEPS[*]}")"
    exit 1
fi

(( DRY_RUN )) && { info "dry run finished; nothing was changed"; exit 0; }

info "all steps finished"
info "reboot now, then see 'After the script' in README.md for what is left to do by hand"
