
load("//platforms:platforms.bzl", "CPUS", "OS")

_def declare_platforms():
    for bzlcpu, aliascpu in CPUS:
        for os in OS:
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
