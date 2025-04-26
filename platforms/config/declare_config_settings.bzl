load("@bazel_skylib//lib:selects.bzl", "selects")
load("//platforms:common.bzl", _supported_target = "SUPPORTED_TARGETS")

def declare_config_settings():
    for (target_os, target_cpu) in _supported_target:
        selects.config_setting_group(
            name = "{}_{}".format(target_os, target_cpu),
            match_all = [
                "@platforms//cpu:{}".format(target_cpu),
                "@platforms//os:{}".format(target_os),
            ],
        )
