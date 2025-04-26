load("//constraints/libc:libc_versions.bzl", "LIBCS")
load("//platforms:platforms.bzl", "CPUS", "LIBC_OS")

def declare_platforms_libc_aware():
    for bzlcpu, aliascpu in CPUS:
        for os in LIBC_OS:
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
