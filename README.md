# supplychain

## Purpose

this repository houses the terraform codes for pulling manifest files and fetches release metadata for the following areas

- Linux Distros (alma, debian, flatcar, nixos)
- software packages (pulling release metadata directly from github/source)
- GPG keys and obtain the key's fingerprint

It encapsulates the result into a json and publishes on my personal r2 bucket on cloudflare, so that it can be consumes as the source of truth via http for other projects
that has the need to fetch aforementioned info without reaching to the source and performing any transform to the data.
