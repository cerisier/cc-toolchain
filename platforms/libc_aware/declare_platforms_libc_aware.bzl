load("//constraints/libc:libc_versions.bzl", _libc_versions = "LIBCS")
load("//platforms:common.bzl", _arch_aliases = "ARCH_ALIASES", _libc_supported_target = "LIBC_SUPPORTED_TARGETS")

def declare_platforms_libc_aware():
    for target_os, target_cpu in _libc_supported_target:
        for libc in _libc_versions:
            # We need a specific unconstrained group to be avoid multiple match with non libc aware configs
            # Like when selecting against a specific libc version and needing a value for the unconstrained libc
            native.platform(
                name = "{}_{}_{}".format(target_os, target_cpu, libc),
                constraint_values = [
                    "@platforms//cpu:{}".format(target_cpu),
                    "@platforms//os:{}".format(target_os),
                    "//constraints/libc:{}".format(libc),
                ],
                visibility = ["//visibility:public"],
            )

            for alias in _arch_aliases.get(target_cpu, []):
                native.platform(
                    name = "{}_{}_{}".format(target_os, alias, libc),
                    constraint_values = [
                        "@platforms//cpu:{}".format(target_cpu),
                        "@platforms//os:{}".format(target_os),
                        "//constraints/libc:{}".format(libc),
                    ],
                    visibility = ["//visibility:public"],
                )
