#!/usr/bin/env sh

# set -ex

#TODO: Handle libc_nonshared.a and co for the sysroot generation.
for arg in "$@"; do
    filename=$(basename "$arg")
    # get the name of the file without the extension
    name="${filename%.*}"

    cp $arg "$OUTPUT_DIR"
    if [ "$filename" != "ld.so" ]; then
        echo "INPUT($filename)" > "$OUTPUT_DIR/${filename%%.so*}.so"
        # ln -s "$filename" "$OUTPUT_DIR/${filename%%.so*}.so"
    fi
done

