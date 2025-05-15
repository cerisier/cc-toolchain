load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")

cc_library(
    name = "kernel_headers",
    hdrs = glob([
        "include/**",
    ]),
    includes = [
        "include",
    ],
    visibility = ["//visibility:public"],
)

directory(
    name = "kernel_headers_top_directory",
    srcs = glob([
        "include/**",
    ]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "kernel_headers_directory",
    path = "include",
    parent = ":kernel_headers_top_directory",
    visibility = ["//visibility:public"],
)
