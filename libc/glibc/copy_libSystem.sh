#!/usr/bin/env sh

set -ex

LIBSYSTEM_TBD="$1"

cp "$LIBSYSTEM_TBD" "$OUTPUT_DIR"
for i in c m dl resolv rt util pthread; do
    ln -s "libSystem.tbd" "$OUTPUT_DIR/lib$i.tbd"
done
