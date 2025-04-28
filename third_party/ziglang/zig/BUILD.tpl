load("@cc-toolchain//toolchain/stage2:cc_stage2_library.bzl", "cc_stage2_library")
load("@cc-toolchain//toolchain/stage2:cc_stage2_static_library.bzl", "cc_stage2_static_library")
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@cc-toolchain//third_party/ziglang/zig:helpers.bzl", "glibc_includes", "glibc_headers", "linux_system_headers")

alias(
    name = "glibc_abilists",
    actual = "lib/libc/glibc/abilists",
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_init",
    copts = [
        "-nostdinc",
    ],
    features = ["-default_compile_flags"],
    srcs = ["lib/libc/glibc/csu/init.c"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_abi_note",
    srcs = [
        "lib/libc/glibc/csu/abi-note.S",
    ],
    copts = [
        "-nostdinc",
        "-Wa,--noexecstack",
    ],
    local_defines = [
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        "TOP_NAMESPACE=glibc",
        "ASSEMBLER",
    ],
    features = ["-default_compile_flags"],
    hdrs = glob(["lib/libc/glibc/**"]),
    includes = [
        "lib/libc/glibc/csu",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [":gnu_libc_headers"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_start",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": ["lib/libc/glibc/sysdeps/x86_64/start.S"],
        "@cc-toolchain//platforms/config:linux_aarch64": ["lib/libc/glibc/sysdeps/aarch64/start.S"],
    }, no_match_error = "Unsupported platform"),
    copts = [
        "-nostdinc",
        "-Wno-nonportable-include-path",
        "-Wa,--noexecstack",
        "-include",
        "$(location lib/libc/glibc/include/libc-modules.h)",
        "-DMODULE_NAME=libc",
        "-include",
        "$(location lib/libc/glibc/include/libc-symbols.h)",
    ],
    features = ["-default_compile_flags"],
    local_defines = [
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        "PIC",
        "SHARED",
        "TOP_NAMESPACE=glibc",
        "ASSEMBLER",
    ],
    additional_compiler_inputs = [
        "lib/libc/glibc/include/libc-modules.h",
        "lib/libc/glibc/include/libc-symbols.h",
    ],
    hdrs = glob(["lib/libc/glibc/**"]),

    # hdrs = glob([
    #     "lib/libc/glibc/**/*.h",
    # ], exclude = [
    #     "lib/libc/glibc/sysdeps/**",
    #     "lib/libc/glibc/include/**",
    # ]) + glob([
    #     "lib/libc/glibc/include/*.h",
    #     "lib/libc/glibc/include/*.h",
    # ])
    # + glob(
    #     [
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/x86_64/**",
    #         "lib/libc/glibc/sysdeps/x86_64/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/generic/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/include/**",
    #     ],
    #     allow_empty = True
    # ) + glob(
    #     [
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/*",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/bits/**",
    #         "lib/libc/glibc/sysdeps/unix/sysv/linux/sys/**",
    #     ],
    #     allow_empty = True
    # )
    # + glob([
    #         # "lib/libc/glibc/sysdeps/nptl/**",
    #         "lib/libc/glibc/sysdeps/pthread/**",
    #         "lib/libc/glibc/sysdeps/unix/x86_64/**",
    #         # "lib/libc/glibc/sysdeps/x86_64/**",
    #         "lib/libc/glibc/sysdeps/generic/**",
    #     ],
    #     allow_empty = True
    # ),
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    implementation_deps = [
        ":linux_system_headers",
        ":gnu_libc_headers",
    ],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "glibc_Scrt1",
    deps = [":glibc_start", ":glibc_init", ":glibc_abi_note"],
    visibility = ["//visibility:public"],
)

cc_stage2_static_library(
    name = "glibc_Scrt1.static",
    deps = [":glibc_Scrt1"],
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "posix_headers",
    includes = [
        "lib/include",
    ],
    hdrs = glob(["lib/include/**"]),
    visibility = ["//visibility:public"],
)

directory(
    name = "posix_headers_directory",
    srcs = glob([
        "lib/include/**",
    ]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "include",
    path = "lib/include",
    parent = ":posix_headers_directory",
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "linux_system_headers",
    hdrs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
        "@platforms//os:macos": [],
    }, no_match_error = "Unsupported platform"),
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86"),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64"),
        "@platforms//os:macos": [],
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

directory(
    name = "linux_system_headers_directory",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": linux_system_headers("x86", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": linux_system_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "linux_system_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//platforms/config:linux_x86_64": "lib/libc/include/x86-linux-any",
        "@cc-toolchain//platforms/config:linux_aarch64": "lib/libc/include/aarch64-linux-any",
    }, no_match_error = "Unsupported platform"),
    parent = ":linux_system_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "linux_system_headers_generic_directory",
    path = "lib/libc/include/any-linux-any",
    parent = ":linux_system_headers_directory",
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "gnu_libc_headers",
    # order matters
    includes = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64"),
        "@platforms//os:macos": ["lib/libc/include/any-macos-any"],
    }, no_match_error = "Unsupported platform"),
    hdrs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64", as_glob = True),
        "@platforms//os:macos": glob(["lib/libc/include/any-macos-any/**"]),
    }, no_match_error = "Unsupported platform"),
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }),
    visibility = ["//visibility:public"],
)

# pub fn compilerRtOptMode(comp: Compilation) std.builtin.OptimizeMode {
#     if (comp.debug_compiler_runtime_libs) {
#         return comp.root_mod.optimize_mode;
#     }
#     const target = comp.root_mod.resolved_target.result;
#     switch (comp.root_mod.optimize_mode) {
#         .Debug, .ReleaseSafe => return target_util.defaultCompilerRtOptimizeMode(target),
#         .ReleaseFast => return .ReleaseFast,
#         .ReleaseSmall => return .ReleaseSmall,
#     }
# }

# pub fn defaultCompilerRtOptimizeMode(target: std.Target) std.builtin.OptimizeMode {
#     if (target.cpu.arch.isWasm() and target.os.tag == .freestanding) {
#         return .ReleaseSmall;
#     } else {
#         return .ReleaseFast;
#     }
# }

cc_stage2_library(
    # glibc_c_nonshared
    name = "c_nonshared",
    copts = [
        "-O2", # libc must be compiled with optimizations (should match with above)
        "-std=gnu11",
        "-fgnu89-inline",
        "-fmerge-all-constants",
        "-frounding-math",
        "-Wno-unsupported-floating-point-opt", # For targets that don't support -frounding-math.
        "-fno-common",
        "-fmath-errno",
        "-ftls-model=initial-exec",
        "-Wno-ignored-attributes",
        "-Qunused-arguments",

        "-Wno-nonportable-include-path",

        "-include",
        "$(location lib/libc/glibc/include/libc-modules.h)",
        "-include",
        "$(location lib/libc/glibc/include/libc-symbols.h)",
    ],
    local_defines = [
        "NO_INITFINI",
        "_LIBC_REENTRANT",
        "MODULE_NAME=libc",
        # "PIC",
        "LIBC_NONSHARED=1",
        "TOP_NAMESPACE=glibc",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": [
            "CAN_USE_REGISTER_ASM_EBP",
        ],
        "//conditions:default": [],
    }),
    hdrs = glob(["lib/libc/glibc/**"]),
    includes = [
        "lib/libc/glibc/csu",
    ] + select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_includes("x86_64"),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_includes("aarch64"),
    }),
    srcs = [
        "lib/libc/glibc/stdlib/atexit.c",
        "lib/libc/glibc/stdlib/at_quick_exit.c",
        "lib/libc/glibc/sysdeps/pthread/pthread_atfork.c",
        "lib/libc/glibc/debug/stack_chk_fail_local.c",

        # if libc <= 2.32
        # libc_nonshared.a redirected stat functions to xstat until glibc 2.33,
        # when they were finally versioned like other symbols.
        
        "lib/libc/glibc/io/stat-2.32.c",
        "lib/libc/glibc/io/fstat-2.32.c",
        "lib/libc/glibc/io/lstat-2.32.c",
        "lib/libc/glibc/io/stat64-2.32.c",
        "lib/libc/glibc/io/fstat64-2.32.c",
        "lib/libc/glibc/io/lstat64-2.32.c",
        "lib/libc/glibc/io/fstatat-2.32.c",
        "lib/libc/glibc/io/fstatat64-2.32.c",
        "lib/libc/glibc/io/mknodat-2.32.c",
        "lib/libc/glibc/io/mknod-2.32.c",

        # if libc <= 2.33
        # __libc_start_main used to require statically linked init/fini callbacks
        # until glibc 2.34 when they were assimilated into the shared library.
        "lib/libc/glibc/csu/elf-init-2.33.c",
    ],
    additional_compiler_inputs = [
        "lib/libc/glibc/include/libc-modules.h",
        "lib/libc/glibc/include/libc-symbols.h",
    ],
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }) + [
        ":posix_headers",
        ":gnu_libc_headers",
    ],
    visibility = ["//visibility:public"],
)

directory(
    name = "macos_libc_headers_base_directory",
    srcs = glob(["lib/libc/include/any-macos-any/**"]),
)

subdirectory(
    name = "macos_libc_headers_directory",
    path = "lib/libc/include/any-macos-any",
    parent = ":macos_libc_headers_base_directory",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libSystem.tbd",
    srcs = ["lib/libc/darwin/libSystem.tbd"],
    visibility = ["//visibility:public"],
)

directory(
    name = "glibc_headers_directory",
    srcs = select({
        "@cc-toolchain//platforms/config:linux_x86_64": glibc_headers("x86_64", as_glob = True),
        "@cc-toolchain//platforms/config:linux_aarch64": glibc_headers("aarch64", as_glob = True),
    }, no_match_error = "Unsupported platform"),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "glibc_headers_arch_specific_directory",
    path = select({
        "@cc-toolchain//platforms/config:linux_x86_64": "lib/libc/include/x86_64-linux-gnu",
        "@cc-toolchain//platforms/config:linux_aarch64": "lib/libc/include/aarch64-linux-gnu",
    }, no_match_error = "Unsupported platform"),
    parent = ":glibc_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "glibc_headers_generic_directory",
    path = "lib/libc/include/generic-glibc",
    parent = ":glibc_headers_directory",
    visibility = ["//visibility:public"],
)

COMMON_CXX_DEFINES = [
    "_LIBCPP_ABI_VERSION=1",
    "_LIBCPP_ABI_NAMESPACE=__1",
    "_LIBCPP_HAS_THREADS", # HANDLE NO THREADS
    "_LIBCPP_HAS_MONOTONIC_CLOCK",
    "_LIBCPP_HAS_TERMINAL",
    "_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS",
    "_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS",
    "_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS",
    "_LIBCPP_HAS_FILESYSTEM", # HANDLE NO FILEYSSTEM
    "_LIBCPP_HAS_RANDOM_DEVICE",
    "_LIBCPP_HAS_LOCALIZATION",
    "_LIBCPP_HAS_UNICODE",
    "_LIBCPP_HAS_WIDE_CHARACTERS",
    "_LIBCPP_HAS_NO_STD_MODULES",
    "_LIBCPP_HAS_TIME_ZONE_DATABASE", # LINUX
    "_LIBCPP_PSTL_BACKEND_SERIAL",
    "_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE",
    # "_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION", # GLIBC < 2.16
    "_LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS",
] + select({
    "@cc-toolchain//constraints/libc:musl": [
        "_LIBCPP_HAS_MUSL_LIBC",
        "_LIBCXX_HAS_MUSL_LIBC",
    ],
    "//conditions:default": [
        "_LIBCXX_HAS_NOMUSL_LIBC",
        "_LIBCPP_HAS_NOMUSL_LIBC",
    ],
})

cc_stage2_library(
    name = "c++abi",
    defines = COMMON_CXX_DEFINES + [
        "NDEBUG",
        "LIBCXX_BUILDING_LIBCXXABI",
        # DHAVE___CXA_THREAD_ATEXIT_IMPL (gnu but not linux and glibc >= 2.18)
    ],
    copts = [
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
        # "-fPIC", #TODO: Support PIC
        "-nostdinc",
        "-nostdinc++",
        "-fstrict-aliasing",
        "-std=c++23",
        "-Wno-user-defined-literals",
        "-Wno-covered-switch-default",
        "-Wno-suggest-override",
    ],
    includes = [
        "lib/libcxx/include",
        "lib/libcxx/src",
        "lib/libcxxabi/include",
        "lib/libcxxabi/src",
        "lib/libcxx/libc",
    ],
    hdrs = glob([
        "lib/libcxx/include/**",
        "lib/libcxxabi/include/**",
        "lib/libcxx/libc/**",
    ]),
    textual_hdrs = glob([
        "lib/libcxx/src/**/*.h",
        "lib/libcxx/src/**/*.ipp",
        "lib/libcxxabi/src/**/*.h",
        "lib/libcxxabi/src/**/*.def",
    ]),
    srcs = [
        "lib/libcxxabi/src/abort_message.cpp",
        "lib/libcxxabi/src/cxa_aux_runtime.cpp",
        "lib/libcxxabi/src/cxa_default_handlers.cpp",
        "lib/libcxxabi/src/cxa_demangle.cpp",
        "lib/libcxxabi/src/cxa_exception.cpp",
        "lib/libcxxabi/src/cxa_exception_storage.cpp",
        "lib/libcxxabi/src/cxa_guard.cpp",
        "lib/libcxxabi/src/cxa_handlers.cpp",
        "lib/libcxxabi/src/cxa_noexception.cpp",
        "lib/libcxxabi/src/cxa_personality.cpp",
        "lib/libcxxabi/src/cxa_thread_atexit.cpp", # not if no threads
        "lib/libcxxabi/src/cxa_vector.cpp",
        "lib/libcxxabi/src/cxa_virtual.cpp",
        "lib/libcxxabi/src/fallback_malloc.cpp",
        "lib/libcxxabi/src/private_typeinfo.cpp",
        "lib/libcxxabi/src/stdlib_exception.cpp",
        "lib/libcxxabi/src/stdlib_new_delete.cpp",
        "lib/libcxxabi/src/stdlib_stdexcept.cpp",
        "lib/libcxxabi/src/stdlib_typeinfo.cpp",
    ],
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }) + [
        ":posix_headers",
    ] + select({
        "@cc-toolchain//constraints/libc:musl": [
            "@musl_libc//:musl_libc_headers",
        ],
        "//conditions:default": [
            ":gnu_libc_headers",
        ],
    }),
    visibility = ["//visibility:public"],
)

cc_stage2_library(
    name = "c++",
    defines = COMMON_CXX_DEFINES + [
        "NDEBUG",
        "LIBC_NAMESPACE=__llvm_libc_common_utils",
        "_LIBCPP_BUILDING_LIBRARY",
        "LIBCXX_BUILDING_LIBCXXABI",
        "_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER",
    ],
    features = ["-default_compile_flags"],
    copts = [
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
        "-faligned-allocation", # .zos = -fno-aligned-allocation
        "-nostdinc",
        "-nostdinc++",
        "-std=c++23",
        "-Wno-user-defined-literals",
        "-Wno-covered-switch-default",
        "-Wno-suggest-override",
    ],
    includes = [
        "lib/libcxx/include",
        "lib/libcxx/src",
        "lib/libcxxabi/include",
        "lib/libcxxabi/src",
        "lib/libcxx/libc",
    ],
    hdrs = glob([
        "lib/libcxx/include/**",
        "lib/libcxxabi/include/**",
        "lib/libcxx/libc/**",
    ]),
    textual_hdrs = glob([
        "lib/libcxx/src/**/*.h",
        "lib/libcxx/src/**/*.ipp",
        "lib/libcxxabi/src/**/*.h",
        "lib/libcxxabi/src/**/*.def",
    ]),
    srcs = [
        "lib/libcxx/src/algorithm.cpp",
        "lib/libcxx/src/any.cpp",
        "lib/libcxx/src/bind.cpp",
        "lib/libcxx/src/call_once.cpp",
        "lib/libcxx/src/charconv.cpp",
        "lib/libcxx/src/chrono.cpp",
        "lib/libcxx/src/error_category.cpp",
        "lib/libcxx/src/exception.cpp",
        "lib/libcxx/src/expected.cpp",
        "lib/libcxx/src/filesystem/directory_entry.cpp",
        "lib/libcxx/src/filesystem/directory_iterator.cpp",
        "lib/libcxx/src/filesystem/filesystem_clock.cpp",
        "lib/libcxx/src/filesystem/filesystem_error.cpp",
        # omit int128_builtins.cpp because it provides __muloti4 which is already provided
        # by compiler_rt and crashes on Windows x86_64: https://github.com/ziglang/zig/issues/10719
        # "lib/libcxx/src/filesystem/int128_builtins.cpp",
        "lib/libcxx/src/filesystem/operations.cpp",
        "lib/libcxx/src/filesystem/path.cpp",
        "lib/libcxx/src/fstream.cpp",
        "lib/libcxx/src/functional.cpp",
        "lib/libcxx/src/hash.cpp",
        "lib/libcxx/src/ios.cpp",
        "lib/libcxx/src/ios.instantiations.cpp",
        "lib/libcxx/src/iostream.cpp",
        "lib/libcxx/src/locale.cpp",
        "lib/libcxx/src/memory.cpp",
        "lib/libcxx/src/memory_resource.cpp",
        "lib/libcxx/src/new.cpp",
        "lib/libcxx/src/new_handler.cpp",
        "lib/libcxx/src/new_helpers.cpp",
        "lib/libcxx/src/optional.cpp",
        "lib/libcxx/src/ostream.cpp",
        "lib/libcxx/src/print.cpp",
        # "lib/libcxx/src/pstl/libdispatch.cpp",
        "lib/libcxx/src/random.cpp",
        "lib/libcxx/src/random_shuffle.cpp",
        "lib/libcxx/src/regex.cpp",
        "lib/libcxx/src/ryu/d2fixed.cpp",
        "lib/libcxx/src/ryu/d2s.cpp",
        "lib/libcxx/src/ryu/f2s.cpp",
        "lib/libcxx/src/stdexcept.cpp",
        "lib/libcxx/src/string.cpp",
        "lib/libcxx/src/strstream.cpp",
        # "lib/libcxx/src/support/ibm/mbsnrtowcs.cpp",
        # "lib/libcxx/src/support/ibm/wcsnrtombs.cpp",
        # "lib/libcxx/src/support/ibm/xlocale_zos.cpp",
        # "lib/libcxx/src/support/win32/locale_win32.cpp",
        # "lib/libcxx/src/support/win32/support.cpp",
        "lib/libcxx/src/system_error.cpp",
        "lib/libcxx/src/typeinfo.cpp",
        "lib/libcxx/src/valarray.cpp",
        "lib/libcxx/src/variant.cpp",
        "lib/libcxx/src/vector.cpp",
        "lib/libcxx/src/verbose_abort.cpp",
    ] + [
        # thread files
        "lib/libcxx/src/atomic.cpp",
        "lib/libcxx/src/barrier.cpp",
        "lib/libcxx/src/condition_variable.cpp",
        "lib/libcxx/src/condition_variable_destructor.cpp",
        "lib/libcxx/src/future.cpp",
        "lib/libcxx/src/mutex.cpp",
        "lib/libcxx/src/mutex_destructor.cpp",
        "lib/libcxx/src/shared_mutex.cpp",
        # "lib/libcxx/src/support/win32/thread_win32.cpp",
        "lib/libcxx/src/thread.cpp",
    ],
    implementation_deps = select({
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
        "//conditions:default": [],
    }) + [
        ":posix_headers",
    ] + select({
        "@cc-toolchain//constraints/libc:musl": [
            "@musl_libc//:musl_libc_headers",
        ],
        "//conditions:default": [
            ":gnu_libc_headers",
        ],
    }),
    visibility = ["//visibility:public"],
)

directory(
    name = "libcxx_headers_directory",
    srcs = glob([
        "lib/libcxx/include/**",
        "lib/libcxxabi/include/**",
    ]),
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libcxx/include",
    path = "lib/libcxx/include",
    parent = ":libcxx_headers_directory",
    visibility = ["//visibility:public"],
)

subdirectory(
    name = "libcxxabi/include",
    path = "lib/libcxxabi/include",
    parent = ":libcxx_headers_directory",
    visibility = ["//visibility:public"],
)

## libunwind

cc_stage2_library(
    name = "libunwind",
    copts = [
        "-nostdinc",
        "-Wa,--noexecstack",
        "-fvisibility=hidden",
        "-fvisibility-inlines-hidden",
        "-fvisibility-global-new-delete=force-hidden",
        "-Wno-bitwise-conditional-parentheses",
        "-Wno-visibility",
        "-Wno-incompatible-pointer-types",
        "-Wno-dll-attribute-on-redeclaration",
    ],
    conlyopts = [
        "-std=c99",
        "-fexceptions",
    ],
    cxxopts = [
        "-fno-exceptions",
        "-fno-rtti",
    ],
    features = ["-default_compile_flags"],
    local_defines = [
        "_LIBUNWIND_DISABLE_VISIBILITY_ANNOTATIONS",

        # This is intentionally always defined because the macro definition means, should it only
        # build for the target specified by compiler defines. Since we pass -target the compiler
        # defines will be correct.
        "_LIBUNWIND_IS_NATIVE_ONLY",
        "_DEBUG",
        # "_LIBUNWIND_HAS_NO_THREADS", # ANY_NON_SINGLE_THREADED
        # "_DCOMPILER_RT_ARMHF_TARGET", # ARM
    ],
    hdrs = glob([
        "lib/libunwind/include/**",
        "lib/libunwind/src/*.h",
        "lib/libunwind/src/*.hpp",
    ]),
    includes = [
        "lib/libunwind/include",
        "lib/libunwind/src",
    ],
    # textual_hdrs = glob([
    #     "lib/libunwind/src/*.h"
    # ]),
    srcs = [
        "lib/libunwind/src/UnwindLevel1.c",
        "lib/libunwind/src/UnwindLevel1-gcc-ext.c",
        "lib/libunwind/src/Unwind-sjlj.c",
        "lib/libunwind/src/Unwind-wasm.c",
        "lib/libunwind/src/UnwindRegistersRestore.S",
        "lib/libunwind/src/UnwindRegistersSave.S",
        "lib/libunwind/src/gcc_personality_v0.c",

        "lib/libunwind/src/libunwind.cpp",
        "lib/libunwind/src/Unwind-EHABI.cpp",
        "lib/libunwind/src/Unwind-seh.cpp",
        "lib/libunwind/src/Unwind_AIXExtras.cpp",
    ],
    implementation_deps = select({
        "@platforms//os:macos": [],
        "@platforms//os:linux": [
            ":linux_system_headers",
        ],
    }) + [
        ":posix_headers",
    ] + select({
        "@cc-toolchain//constraints/libc:musl": [
            "@musl_libc//:musl_libc_headers",
        ],
        "//conditions:default": [
            ":gnu_libc_headers",
        ],
    }),
    visibility = ["//visibility:public"],
)
