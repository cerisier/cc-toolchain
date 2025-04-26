load("@bazel_skylib//lib:selects.bzl", "selects")
load("//platforms:platforms.bzl", "CPUS", "OS")

def declare_config_settings():
    for bzlcpu, _ in CPUS:
        for os in OS:
            selects.config_setting_group(
                name = "{}_{}".format(os, bzlcpu),
                match_all = [
                    "@platforms//cpu:{}".format(bzlcpu),
                    "@platforms//os:{}".format(os),
                ],
            )
