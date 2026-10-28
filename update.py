#!/usr/bin/env python3
"""Prepare a Cask update from a published release and its downloaded archive."""

import argparse
import hashlib
import json
import re
from pathlib import Path


def prepare_update(release, archive, cask, repository):
    if release["draft"] or release["prerelease"]:
        raise ValueError("Homebrew requires a published stable release")
    tag = release["tag_name"]
    if not re.fullmatch(r"v\d+\.\d+\.\d+", tag):
        raise ValueError(f"Unexpected stable release tag: {tag}")
    version = tag[1:]
    name = f"markview-{version}-aarch64.app.zip"
    assets = [asset for asset in release["assets"] if asset["name"] == name]
    if len(assets) != 1:
        raise ValueError(f"Release must contain exactly one {name}")
    asset = assets[0]
    url = f"https://github.com/{repository}/releases/download/{tag}/{name}"
    if asset["browser_download_url"] != url:
        raise ValueError("Unexpected application download URL")
    with archive.open("rb") as file:
        checksum = hashlib.file_digest(file, "sha256").hexdigest()
    if asset.get("digest") != f"sha256:{checksum}":
        raise ValueError("Downloaded archive does not match the release SHA-256")

    expected_url = (
        f'  url "https://github.com/{repository}/releases/download/'
        'v#{version}/markview-#{version}-aarch64.app.zip"'
    )
    if expected_url not in cask:
        raise ValueError("Cask does not use this repository's versioned archive")
    versions = re.findall(r'^  version "(\d+\.\d+\.\d+)"$', cask, re.MULTILINE)
    checksums = re.findall(r'^  sha256 "([0-9a-f]{64})"$', cask, re.MULTILINE)
    if len(versions) != 1 or len(checksums) != 1:
        raise ValueError("Cask must contain one stable version and one SHA-256")
    current = tuple(map(int, versions[0].split(".")))
    incoming = tuple(map(int, version.split(".")))
    if incoming < current:
        return version, None
    if incoming == current:
        if checksum != checksums[0]:
            raise ValueError("An already published Cask version has a different SHA-256")
        return version, None
    updated = re.sub(r'^  version "\d+\.\d+\.\d+"$', f'  version "{version}"', cask, flags=re.MULTILINE)
    updated = re.sub(r'^  sha256 "[0-9a-f]{64}"$', f'  sha256 "{checksum}"', updated, flags=re.MULTILINE)
    return version, updated


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repository", required=True)
    for name in ("release", "archive", "cask", "output"):
        parser.add_argument(f"--{name}", required=True, type=Path)
    args = parser.parse_args()
    try:
        version, updated = prepare_update(
            json.loads(args.release.read_text()), args.archive,
            args.cask.read_text(), args.repository,
        )
    except ValueError as error:
        parser.exit(1, f"{error}\n")
    if updated is not None:
        args.output.write_text(updated)
    print(f"version={version}")
    print(f"changed={'true' if updated is not None else 'false'}")


if __name__ == "__main__":
    main()
