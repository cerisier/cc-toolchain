load("//constraints/libc:libc_versions.bzl", "LIBCS")

_CPUS = (("x86_64", "amd64"), ("aarch64", "arm64"))

_LIBC_OS = [
    "linux",
]

def declare_platforms_libc_aware():
    for bzlcpu, aliascpu in _CPUS:
        for os in _LIBC_OS:
            for libc in LIBCS:
                native.platform(
                    name = "{}_{}_{}".format(os, bzlcpu, libc),
                    constraint_values = [
                        "@platforms//cpu:{}".format(bzlcpu),
                        "@platforms//os:{}".format(os),
                        "//constraints/libc:{}".format(libc),
                    ],
                    visibility = ["//visibility:public"],
                )
                native.platform(
                    name = "{}_{}_{}".format(os, aliascpu, libc),
                    constraint_values = [
                        "@platforms//cpu:{}".format(bzlcpu),
                        "@platforms//os:{}".format(os),
                        "//constraints/libc:{}".format(libc),
                    ],
                    visibility = ["//visibility:public"],
                )
