#!/usr/bin/env bash
set -e

patch_wine="wine-tkg-git/wine-tkg-patches"
TKG_PATCHES=(
    "$patch_wine/proton/LAA/LAA-unix-staging.patch"
    "$patch_wine/proton/msvcrt_nativebuiltin/msvcrt_nativebuiltin_mainline.patch"
    "$patch_wine/proton/proton-win10-default/proton-win10-default.patch"
    "$patch_wine/hotfixes/GE/wine-hotfixes/pending/unity_crash_hotfix.patch"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$0")"
echo $(pwd)
# cd $SCRIPT_DIR
TKG_COMMIT=$(grep '^_tkg_commit=' PKGBUILD | cut -d'=' -f2)
WINE_COMMIT=$(grep '^_wine_commit=' PKGBUILD | cut -d'=' -f2)
STAGING_COMMIT=$(grep '^_staging_commit=' PKGBUILD | cut -d'=' -f2)

if [[ -z "$TKG_COMMIT" ]] || [[ -z "$WINE_COMMIT" ]] || [[ -z "$STAGING_COMMIT" ]]; then
    echo "ERROR: Could not read commit hashes from PKGBUILD!"
    exit 1
fi

sync_repo() {
    local name=$1 url=$2 commit=$3 paths=$4
    echo "==> Sync $name..."

		if [[ ! -d "$name" ]]; then
        echo "    Cloning..."
        if [[ -n "$paths" ]]; then
						git clone -q --depth=1 --filter=blob:none --sparse --no-checkout "$url" "$name"
            git -C "$name" sparse-checkout init --no-cone
            git -C "$name" sparse-checkout set $paths
				else
						git clone --depth=1 --filter=blob:none --no-checkout "$url" "$name"
				fi
		elif [[ "$(git -C "$name" rev-parse HEAD 2>/dev/null)" == "$commit" ]]; then
				return
		else
        echo "  Updating..."
		fi

		git -C "$name" fetch --depth=1 origin "$commit"
    git -C "$name" checkout -q "$commit"
		# git -C "$name" switch -q --detach "$commit"
		echo "$name at ${commit:0:8}"
}

sync_repo \
    "wine-staging" \
    "https://github.com/wine-staging/wine-staging.git" \
    "$STAGING_COMMIT"

sync_repo \
    "wine" \
    "https://github.com/wine-mirror/wine.git" \
    "$WINE_COMMIT"

sync_repo \
    "wine-tkg-git" \
    "https://github.com/Frogging-Family/wine-tkg-git.git" \
    "$TKG_COMMIT" \
		"${TKG_PATCHES[*]}"
