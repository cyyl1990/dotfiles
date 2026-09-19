#!/usr/bin/env bash
# Remove a package via paru (paru -Rns), prompting for the name.
# Held open so you can read the result.
set -uo pipefail

read -r -p "Package to remove (paru -Rns): " pkg
if [[ -z "${pkg:-}" ]]; then
    echo "No package name entered. Exiting."
    read -r -p "Press Enter to close…" _
    exit 1
fi

paru -Rns $pkg
rc=$?
echo ""
if [[ $rc -eq 0 ]]; then
    echo "✓ Removed: $pkg"
else
    echo "✗ paru exited with code $rc"
fi
read -r -p "Press Enter to close…" _
