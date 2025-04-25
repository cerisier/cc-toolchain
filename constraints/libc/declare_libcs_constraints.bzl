load(":libc_versions.bzl", "LIBCS")

def declare_libcs_constraints():
    for libc in LIBCS:
        native.constraint_value(
            name = libc,
            constraint_setting = "variant",
        )
