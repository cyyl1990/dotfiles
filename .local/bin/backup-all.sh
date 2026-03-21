#!/bin/bash
set -e

SNAP_DIR="/.snapshots"
DEST="/media/backup"

GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${BLUE}=== BTRFS BACKUP START ===${RESET}"

# ===== ROOT =====
LAST=$(sudo ls $SNAP_DIR | grep '^root-' | sort -V | tail -n1)
[ -z "$LAST" ] && echo -e "${RED}Thiếu root snapshot${RESET}" && exit 1

NUM=${LAST#root-}
NEXT=$((NUM + 1))
NEW="root-$NEXT"

echo -e "${YELLOW}[ROOT] $LAST -> $NEW${RESET}"

sudo btrfs subvolume snapshot -r / $SNAP_DIR/$NEW
sudo btrfs send -p $SNAP_DIR/$LAST $SNAP_DIR/$NEW | pv | sudo btrfs receive $DEST

echo -e "${GREEN}[ROOT] DONE${RESET}"

# ===== HOME =====
LAST_H=$(sudo ls $SNAP_DIR | grep '^home-' | sort -V | tail -n1)
[ -z "$LAST_H" ] && echo -e "${RED}Thiếu home snapshot${RESET}" && exit 1

NUM_H=${LAST_H#home-}
NEXT_H=$((NUM_H + 1))
NEW_H="home-$NEXT_H"

echo -e "${YELLOW}[HOME] $LAST_H -> $NEW_H${RESET}"

sudo btrfs subvolume snapshot -r /home $SNAP_DIR/$NEW_H
sudo btrfs send -p $SNAP_DIR/$LAST_H $SNAP_DIR/$NEW_H | pv | sudo btrfs receive $DEST

echo -e "${GREEN}[HOME] DONE${RESET}"

echo -e "${GREEN}=== BACKUP COMPLETED ===${RESET}"
