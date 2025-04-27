load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//toolchain/stage2:cc_stage2_shared_library.bzl", "cc_stage2_shared_library")

def make_glibc_shared_library(
    lib_name,
    lib_version,
    srcs,
    extra_link_flags = [],
):
    cc_library(
        name = lib_name,
        srcs = srcs,
    )

    soname = lib_name + ".so{}".format("."+lib_version if len(lib_version) > 0 else "")

    cc_stage2_shared_library(
        name = lib_name + ".so",
        deps = [lib_name],
        additional_linker_inputs = [
            ":all.map",
        ],
        user_link_flags = [
            "-Wl,--version-script=$(location :all.map)",
            "-Wl,-soname,{}".format(soname)
        ] + extra_link_flags,
        shared_lib_name = soname,
        visibility = ["//visibility:public"],
    )

    return lib_name + ".so"
