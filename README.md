# local-aur
update package to lasted version for testing

## Build
Example:
```bash
git clone https://github.com/Zebra2711/local-aur.git
cd local-aur/wine
makepkg -Ccris
```

## For Wine Builds with Custom Patches:

To apply your own patches during the Wine build process, place them in the staging-patches folder. Then, ensure you set the variable `USE_STAGING_PATCHES=1` within the PKGBUILD file.
