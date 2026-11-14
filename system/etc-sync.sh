#!/usr/bin/env bash
#
# Keeps copies of a few system config files from /etc in this repo.
#
# These files are COPIED, never symlinked. The login screen runs as a
# separate user that cannot read the home folder, and system config should
# stay owned by root, so stow is the wrong tool for them.
#
#   ./etc-sync.sh backup    copy the live files from /etc into system/etc/
#   ./etc-sync.sh diff      show how the live files differ from the repo copies
#   ./etc-sync.sh restore   install the repo copies into /etc (asks per file)
#
# To track another file, add its full path to FILES below and run backup.

set -euo pipefail

FILES=(
    /etc/greetd/config.toml
    /etc/pam.d/greetd
    /etc/hyprlogin/hyprland-greeter.conf
    /etc/hyprlogin/hyprland-greeter.lua
    /etc/hyprlogin/hyprlogin.conf
)

# folder this script lives in, even when called through a symlink
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
MIRROR="$HERE/etc"

# only for testing against a fake root folder; leave unset in normal use
ROOT="${ETC_SYNC_ROOT:-}"

repo_copy() { printf '%s/%s' "$MIRROR" "${1#/etc/}"; }

backup() {
    local f dest
    for f in "${FILES[@]}"; do
        dest="$(repo_copy "$f")"
        if [[ ! -r "$ROOT$f" ]]; then
            echo "skipped (missing or unreadable): $f"
            continue
        fi
        mkdir -p "$(dirname "$dest")"
        if [[ -f "$dest" ]] && cmp -s "$ROOT$f" "$dest"; then
            echo "unchanged: $f"
        else
            cp "$ROOT$f" "$dest"
            echo "backed up: $f"
        fi
    done
    echo
    echo "Review with 'git diff', then commit. This repo is public: check"
    echo "that nothing private is in these files before pushing."
}

show_diff() {
    local f src changed=0
    for f in "${FILES[@]}"; do
        src="$(repo_copy "$f")"
        if [[ ! -f "$src" ]]; then
            echo "not in repo yet: $f"
        elif [[ ! -r "$ROOT$f" ]]; then
            echo "missing on this system: $f"
            changed=1
        elif ! cmp -s "$ROOT$f" "$src"; then
            # left side = live file, right side = repo copy
            diff -u --label "live $f" --label "repo $f" "$ROOT$f" "$src" || true
            changed=1
        fi
    done
    (( changed )) || echo "Live files match the repo copies."
}

restore() {
    local f src answer
    for f in "${FILES[@]}"; do
        src="$(repo_copy "$f")"
        if [[ ! -f "$src" ]]; then
            echo "not in repo, skipped: $f"
            continue
        fi
        if [[ -r "$ROOT$f" ]] && cmp -s "$ROOT$f" "$src"; then
            echo "already current: $f"
            continue
        fi

        echo
        echo "=== $f ==="
        if [[ -r "$ROOT$f" ]]; then
            diff -u --label "live $f" --label "repo $f" "$ROOT$f" "$src" || true
        else
            echo "(not present on this system; would be created)"
        fi

        read -r -p "Install the repo copy over $f? [y/N] " answer
        if [[ "$answer" != [yY] ]]; then
            echo "left alone: $f"
            continue
        fi

        # keep the previous version beside it, then install as root:root 644
        if [[ -e "$ROOT$f" ]]; then
            sudo cp -p "$ROOT$f" "$ROOT$f.bak"
        fi
        sudo install -D -m 644 -o root -g root "$src" "$ROOT$f"
        echo "installed: $f (previous version kept as $f.bak)"
    done
}

case "${1:-}" in
    backup)  backup ;;
    diff)    show_diff ;;
    restore) restore ;;
    *)
        echo "usage: $(basename "$0") backup | diff | restore" >&2
        exit 2
        ;;
esac
