
load("//platforms:common.bzl", _arch_aliases = "ARCH_ALIASES", _supported_target = "SUPPORTED_TARGETS")

def declare_platforms():
    for (target_os, target_cpu) in _supported_target:
        native.platform(
            name = "{}_{}".format(target_os, target_cpu),
            constraint_values = [
                "@platforms//cpu:{}".format(target_cpu),
                "@platforms//os:{}".format(target_os),
            ],
            visibility = ["//visibility:public"],
        )

        for alias in _arch_aliases.get(target_cpu, []):
            native.platform(
                name = "{}_{}".format(target_os, alias),
                constraint_values = [
                    "@platforms//cpu:{}".format(target_cpu),
                    "@platforms//os:{}".format(target_os),
                ],
                visibility = ["//visibility:public"],
            )
