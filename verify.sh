#!/usr/bin/env bash
# Exercise a local tap using the official `0.4.1` and current release archives.
set -euo pipefail

previous_zip=$(realpath "${1:?usage: verify.sh PREVIOUS_ZIP CURRENT_ZIP}")
current_zip=$(realpath "${2:?usage: verify.sh PREVIOUS_ZIP CURRENT_ZIP}")
root=$(cd "$(dirname "$0")" && pwd)
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_INSTALL_CLEANUP=1

if brew list --cask markview >/dev/null 2>&1; then
	echo "Uninstall the existing Homebrew cask before running this test." >&2
	exit 1
fi

work=$(mktemp -d)
suffix=$(basename "$work" | tr '[:upper:]' '[:lower:]')
tap="markview-validation/$suffix"
tapdir="$(brew --repository)/Library/Taps/markview-validation/homebrew-$suffix"
cask=$tap/markview
cleanup() {
	if brew list --cask markview >/dev/null 2>&1; then
		brew uninstall --cask "$cask"
	fi
	brew untrust --cask "$cask"
	brew untap "$tap"
	rm -r "$work"
}
trap cleanup EXIT
mkdir -p "$tapdir/Casks" "$work/Applications"
git init -q "$tapdir"
git -C "$tapdir" remote add origin "https://github.com/markview-validation/homebrew-$suffix"
cp "$root/Casks/markview.rb" "$tapdir/Casks/markview.rb"
brew trust --cask "$cask"

previous_sha=7370bacabc665cf6de4d2e327921c8bf13bdae2e5277240785d80d3e504e7d49
current_sha=$(sed -n 's/^  sha256 "\(.*\)"/\1/p' "$root/Casks/markview.rb")
test "$(shasum -a 256 "$previous_zip" | cut -d ' ' -f 1)" = "$previous_sha"
test "$(shasum -a 256 "$current_zip" | cut -d ' ' -f 1)" = "$current_sha"
cp "$current_zip" "$(brew --cache --cask "$cask")"
brew style --cask "$cask"
brew audit --cask --online "$cask"
ditto -x -k "$previous_zip" "$work/Applications"
if brew install --cask --adopt --appdir="$work/Applications" "$cask" >"$work/mismatch.log" 2>&1; then
	echo "Unexpectedly adopted a different version." >&2
	exit 1
fi
rg -q 'existing App is different' "$work/mismatch.log"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$work/Applications/Markview.app/Contents/Info.plist")" = 0.4.1
mv "$work/Applications/Markview.app" "$work/preserved.app"

sed -e 's/version ".*"/version "0.4.1"/' -e "s/$current_sha/$previous_sha/" \
	"$root/Casks/markview.rb" >"$tapdir/Casks/markview.rb"
cp "$previous_zip" "$(brew --cache --cask "$cask")"
brew install --cask --appdir="$work/Applications" "$cask"
cp "$root/Casks/markview.rb" "$tapdir/Casks/markview.rb"
brew upgrade --cask "$cask"
codesign --verify --deep --strict "$work/Applications/Markview.app"
xattr -p com.apple.quarantine "$work/Applications/Markview.app"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$work/Applications/Markview.app/Contents/Info.plist")" = \
	"$(sed -n 's/^  version "\(.*\)"/\1/p' "$root/Casks/markview.rb")"
brew uninstall --cask "$cask"
test ! -e "$work/Applications/Markview.app"
ditto -x -k "$current_zip" "$work/Applications"
brew install --cask --adopt --appdir="$work/Applications" "$cask"
codesign --verify --deep --strict "$work/Applications/Markview.app"
brew uninstall --cask "$cask"
test ! -e "$work/Applications/Markview.app"
echo "PASS: install, upgrade, migration, signature, quarantine, and uninstall"
