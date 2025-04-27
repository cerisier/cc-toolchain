#!/usr/bin/env sh

# set -ex

for arg in "$@"; do
    cp $arg "$OUTPUT_DIR"
done

