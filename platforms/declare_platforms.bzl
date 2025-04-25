load("//platforms/constraints/libc:libc_versions.bzl", "LIBCS")

_CPUS = (("x86_64", "amd64"), ("aarch64", "arm64"))
_OS = [
    "linux",
    "macos",
]

_LIBC_OS = [
    "linux",
]

def declare_platforms():
    for bzlcpu, aliascpu in _CPUS:
        for os in _OS:
            native.platform(
                name = "{}_{}".format(os, bzlcpu),
                constraint_values = [
                    "@platforms//cpu:{}".format(bzlcpu),
                    "@platforms//os:{}".format(os),
                ],
                visibility = ["//visibility:public"],
            )
            native.platform(
                name = "{}_{}".format(os, aliascpu),
                constraint_values = [
                    "@platforms//cpu:{}".format(bzlcpu),
                    "@platforms//os:{}".format(os),
                ],
                visibility = ["//visibility:public"],
            )


def declare_platforms_libc_aware():
    for bzlcpu, aliascpu in _CPUS:
        for os in _LIBC_OS:
            for libc in LIBCS:
                native.platform(
                    name = "{}_{}_{}".format(os, bzlcpu, libc),
                    constraint_values = [
                        "@platforms//cpu:{}".format(bzlcpu),
                        "@platforms//os:{}".format(os),
                        "//platforms/constraints/libc:{}".format(libc),
                    ],
                    visibility = ["//visibility:public"],
                )
                native.platform(
                    name = "{}_{}_{}".format(os, aliascpu, libc),
                    constraint_values = [
                        "@platforms//cpu:{}".format(bzlcpu),
                        "@platforms//os:{}".format(os),
                        "//platforms/constraints/libc:{}".format(libc),
                    ],
                    visibility = ["//visibility:public"],
                )
