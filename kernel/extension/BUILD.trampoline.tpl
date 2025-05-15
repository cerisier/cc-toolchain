load("@toolchains_cc//kernel/extension:make_select_kernel_headers_repository_target.bzl", "make_select_kernel_headers_repository_target")

package(default_visibility = ["//visibility:public"])

alias(
    name = "kernel_headers",
    actual = make_select_kernel_headers_repository_target("kernel_headers"),
)

alias(
    name = "kernel_headers_directory",
    actual = make_select_kernel_headers_repository_target("kernel_headers_directory"),
)
