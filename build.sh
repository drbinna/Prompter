#!/bin/sh
# Builds the prompter. Needs the Xcode Command Line Tools (xcode-select --install).
set -e
cd "$(dirname "$0")"
swiftc -O -o prompter Prompter.swift -framework AppKit
echo "built ./prompter  —  run:  ./prompter scripts/insertion-sort.md"
