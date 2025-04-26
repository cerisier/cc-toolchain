load("//constraints/libc:libc_versions.bzl", "LIBCS")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("//platforms:platforms.bzl", "CPUS", "LIBC_OS")

def declare_config_settings_libc_aware():
    for bzlcpu, _ in CPUS:
        for os in LIBC_OS:
            # We need a specific unconstrained group to be avoid multiple match with non libc aware configs
            # Like when selecting against a specific libc version and needing a value for the unconstrained libc
            selects.config_setting_group(
                name = "{}_{}".format(os, bzlcpu),
                match_all = [
                    "@platforms//cpu:{}".format(bzlcpu),
                    "@platforms//os:{}".format(os),
                    "//constraints/libc:unconstrained",
                ],
            )

            for libc in LIBCS:
                selects.config_setting_group(
                    name = "{}_{}_{}".format(os, bzlcpu, libc),
                    match_all = [
                        "@platforms//cpu:{}".format(bzlcpu),
                        "@platforms//os:{}".format(os),
                        "//constraints/libc:{}".format(libc),
                    ],
                )
