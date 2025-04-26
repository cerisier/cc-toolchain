load("@bazel_skylib//lib:selects.bzl", "selects")
load("//constraints/libc:libc_versions.bzl", _libc_versions = "LIBCS")
load("//platforms:common.bzl", _libc_supported_target = "LIBC_SUPPORTED_TARGETS")

def declare_config_settings_libc_aware():
    for (target_os, target_cpu) in _libc_supported_target:
        # We need a specific unconstrained group to be avoid multiple match with non libc aware configs
        # Like when selecting against a specific libc version and needing a value for the unconstrained libc
        selects.config_setting_group(
            name = "{}_{}".format(target_os, target_cpu),
            match_all = [
                "@platforms//cpu:{}".format(target_cpu),
                "@platforms//os:{}".format(target_os),
                "//constraints/libc:unconstrained",
            ],
        )

        for libc in _libc_versions:
            selects.config_setting_group(
                name = "{}_{}_{}".format(target_os, target_cpu, libc),
                match_all = [
                    "@platforms//cpu:{}".format(target_cpu),
                    "@platforms//os:{}".format(target_os),
                    "//constraints/libc:{}".format(libc),
                ],
            )
