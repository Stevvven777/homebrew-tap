# Markview Homebrew tap

Community tap for the Apple Silicon macOS builds of
[Markview](https://github.com/szdytom/markview). Downloads come directly from
upstream GitHub Releases; this tap does not rebuild or re-sign the application.

## Install, update, and uninstall

```sh
brew install --cask Stevvven777/tap/markview
brew update
brew upgrade --cask Stevvven777/tap/markview
brew uninstall --cask Stevvven777/tap/markview
```

These commands do not need `sudo`. Normal uninstall preserves settings, styles,
and downloaded fonts. The fully qualified installation trusts only this Cask
rather than the entire tap; see Homebrew's [Tap Trust](https://docs.brew.sh/Tap-Trust).

## Existing manual installations

Quit Markview before migrating. Homebrew's `--adopt` can take ownership of an
existing `/Applications/Markview.app` when its version matches the Cask:

```sh
brew install --cask --adopt Stevvven777/tap/markview
```

For a different version, move the old application to a backup location outside
`/Applications`, then install the Cask normally. Keep the backup until the new
application works. Do not remove `~/Library/Application Support/markview`.

## Gatekeeper

The application is ad-hoc signed, without Developer ID signing or notarization.
If macOS blocks launch, review it in System Settings > Privacy & Security and
choose Open Anyway. Updates may require approval again. Tap trust does not
approve an application for Gatekeeper. The Cask does not remove quarantine
attributes or change system security settings.

## Automatic updates

The [Update Markview workflow](https://github.com/Stevvven777/homebrew-tap/actions/workflows/update.yml)
checks the latest stable upstream release every hour. GitHub may delay scheduled
runs. It also supports manual runs, with an optional stable release tag.

The workflow downloads the versioned `.app.zip`, verifies its SHA-256 against the
release asset digest, and updates only the Cask version and checksum. Repeated
runs are skipped; older releases cannot downgrade the Cask. It uses the tap's
own `GITHUB_TOKEN`, restricted to this repository, and needs no extra secret.
GitHub can disable scheduled workflows after 60 days of repository inactivity;
maintainers can re-enable them in Actions.

## Local validation

On an Apple Silicon Mac with Homebrew, Git, and ripgrep, download the upstream
`0.4.1` and current `.app.zip` archives and run:

```sh
bash verify.sh /path/to/markview-0.4.1-aarch64.app.zip /path/to/markview-0.4.2-aarch64.app.zip
```

The test checks archive hashes, Cask format and online audit, installation,
upgrade, matched adoption, mismatched adoption rejection, signatures, quarantine,
and uninstall. It creates a temporary local tap and app directory, then removes
them on exit. It refuses to run when a Homebrew installation of Markview already
exists and leaves manually installed applications alone. Gatekeeper approval is
a separate manual check.
