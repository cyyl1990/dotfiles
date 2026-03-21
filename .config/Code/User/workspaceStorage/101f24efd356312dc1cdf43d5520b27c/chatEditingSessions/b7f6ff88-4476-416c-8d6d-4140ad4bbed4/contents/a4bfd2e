#!/bin/bash

selected_for_backup=()
current_dir="/tmp"
# simulate a situation where "/tmp/file1" exists and "/tmp/testA" is a directory
mkdir -p /tmp/testA
touch /tmp/file1

# result string coming back from fzf: two items selected,
# one file and one directory (directory is the one user is descending into)
result="/tmp/file1
/tmp/testA"

key=""
selection=$(echo "$result" | tail -n +1)
selection=$(echo "$selection" | sed 's/^✔ //')

item_count=$(echo "$selection" | wc -l)

echo "item_count=$item_count"

dir_count=0
last_dir=""
while IFS= read -r item; do
  if [ -d "$item" ]; then
    dir_count=$((dir_count + 1))
    last_dir="$item"
  fi
done <<< "$selection"
echo "dir_count=$dir_count last_dir=$last_dir"

if [ $item_count -gt 1 ]; then
  if [ $dir_count -eq 1 ]; then
    added=0
    while IFS= read -r item; do
      if [ "$item" != "[..]" ] && [ -n "$item" ] && [ "$item" != "$last_dir" ]; then
        selected_for_backup+=("$item")
        added=$((added + 1))
      fi
    done <<< "$selection"
    echo "added items: $added"
    current_dir="$last_dir"
    echo "new current_dir=$current_dir"
  else
    echo "no single directory, just normal add"
  fi
echo "selected_for_backup: ${selected_for_backup[@]}"
fi
