#!/usr/bin/env bash
# Install a package via paru (AUR helper), prompting for the name.
# Held open so you can read the result.
set -uo pipefail

read -r -p "Package to install (paru -S): " pkg
if [[ -z "${pkg:-}" ]]; then
    echo "No package name entered. Exiting."
    read -r -p "Press Enter to close…" _
    exit 1
fi

paru -S --needed $pkg
rc=$?
echo ""
if [[ $rc -eq 0 ]]; then
    echo "✓ Installed: $pkg"
else
    echo "✗ paru exited with code $rc"
fi
read -r -p "Press Enter to close…" _
