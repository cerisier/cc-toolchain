load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//toolchain/bootstrap:cc_bootstrap_shared_library.bzl", "cc_bootstrap_shared_library")

def make_glibc_shared_library(
    lib_name,
    lib_version,
    srcs,
):
    cc_library(
        name = lib_name,
        srcs = srcs,
    )

    cc_bootstrap_shared_library(
        name = lib_name + ".so",
        deps = [lib_name],
        additional_linker_inputs = [
            ":all.map",
        ],
        user_link_flags = [
            "-Wl,--version-script=$(location :all.map)",
        ],
        shared_lib_name = lib_name +".so{}".format("."+lib_version if len(lib_version) > 0 else ""),
        visibility = ["//visibility:public"],
    )

    return lib_name + ".so"
