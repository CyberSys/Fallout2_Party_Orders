#!/bin/bash

set -xeu -o pipefail

export comp_dir="components"
# shellcheck disable=SC2154  # from env.sh
export dat2="wine $bin_dir/dat2.exe"
export dat2a="wine $bin_dir/dat2.exe a -1"
export file_list="file.list"

short_sha="$(git rev-parse --short HEAD)"
# defaults, local build or github non-tagged
export version="git$short_sha"

# tagged build
if [[ -n "${GITHUB_REF-}" ]]; then                 # github build
    if echo "$GITHUB_REF" | grep "refs/tags"; then # tagged
        # shellcheck disable=SC2001  # sed is more readable
        version="$(echo "$GITHUB_REF" | sed 's|refs\/tags\/||')"
        export version
    fi
fi

# data
# shellcheck disable=SC2154  # from env.sh
dat="$mod_name.dat"
# shellcheck disable=SC2154  # from env.sh
mkdir -p "$mods_dir"

cd data
rm -rf text/po # gettext translations
# I don't know how to pack recursively
find . -type f | sed -e 's|^\.\/||' -e 's|\/|\\|g' | sort >../file.list # replace slashes with backslashes
wine "$bin_dir/dat2.exe" a "$dat" @../file.list
cd ..
mv "data/$dat" "$mods_dir/"

# sfall
# shellcheck disable=SC2154  # from workflow yml
sfall_url="https://sourceforge.net/projects/sfall/files/sfall/sfall_${sfall_version}.7z/download"
wget -q "$sfall_url" -O sfall.7z
7zr e sfall.7z ddraw.dll
zip -r "${mod_name}_${version}.zip" ddraw.dll "$mods_dir/" # our package
