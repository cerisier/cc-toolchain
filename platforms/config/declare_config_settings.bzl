load("@bazel_skylib//lib:selects.bzl", "selects")

_CPUS = (("x86_64", "amd64"), ("aarch64", "arm64"))
_OS = [
    "linux",
    "macos",
]

def declare_config_settings():
    for bzlcpu, _ in _CPUS:
        for os in _OS:
            selects.config_setting_group(
                name = "{}_{}".format(os, bzlcpu),
                match_all = [
                    "@platforms//cpu:{}".format(bzlcpu),
                    "@platforms//os:{}".format(os),
                ],
            )
