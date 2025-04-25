_CPUS = (("x86_64", "amd64"), ("aarch64", "arm64"))
_OS = [
    "linux",
    "macos",
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
