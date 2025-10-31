#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: ./personalize.sh <username> [repository_name] [image_name]"
  exit 1
fi

username="$1"
repository_name="${2-}"
image_name="${3-}"

# Helper: run a sed replace in-place with a .bak backup, then remove the backup
replace_in_file() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"
  sed -E -i.bak "s#${pattern}#${replacement}#g" "$file"
  rm -f "${file}.bak"
}

export username repository_name image_name

while IFS= read -r -d '' f; do
  replace_in_file "$f" 'https://github.com/[-_a-zA-Z0-9]+' "https://github.com/${username}"
  replace_in_file "$f" 'ghcr.io/[-_a-zA-Z0-9]+' "ghcr.io/${username}"
done < <(find . -type f -name '*.yaml' -print0)

if [ -n "$repository_name" ]; then
  while IFS= read -r -d '' f; do
    replace_in_file "$f" "https://github.com/${username}/[-_a-zA-Z0-9]+" "https://github.com/${username}/${repository_name}"
  done < <(find . -type f -name '*.yaml' -print0)
fi

if [ -n "$image_name" ]; then
  while IFS= read -r -d '' f; do
    replace_in_file "$f" "ghcr.io/${username}/[-_a-zA-Z0-9]+" "ghcr.io/${username}/${image_name}"
  done < <(find . -type f -name '*.yaml' -print0)
fi

exit 0
