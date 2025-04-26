
def glibc_includes(cpu):
    return [
        "lib/libc/glibc/include",
        "lib/libc/glibc/sysdeps/unix/sysv/linux/{}".format(cpu),
        "lib/libc/glibc/sysdeps/{}".format(cpu),
        "lib/libc/glibc/sysdeps/unix/sysv/linux/generic",
        "lib/libc/glibc/sysdeps/unix/sysv/linux/include",
        "lib/libc/glibc/sysdeps/unix/sysv/linux",
        # "lib/libc/glibc/sysdeps/nptl",
        "lib/libc/glibc/sysdeps/pthread",
        "lib/libc/glibc/sysdeps/unix/sysv",
        "lib/libc/glibc/sysdeps/unix/{}".format(cpu),
        "lib/libc/glibc/sysdeps/unix",
        "lib/libc/glibc/sysdeps/{}".format(cpu),
        "lib/libc/glibc/sysdeps/generic",

        # glibc
        "lib/libc/glibc",
    ]

def musl_libc_internal_headers(arch, as_glob = False):
    paths = [
        "lib/libc/musl/arch/{arch}{pattern}".format(arch = arch, pattern = "/**" if as_glob else ""),
        "lib/libc/musl/arch/generic{pattern}".format(pattern = "/**" if as_glob else ""),
        "lib/libc/musl/src/include{pattern}".format(pattern = "/**" if as_glob else ""),
        "lib/libc/musl/src/internal{pattern}".format(pattern = "/**" if as_glob else ""),
        "lib/libc/musl/ldso{pattern}".format(pattern = "/**" if as_glob else ""),
        "lib/libc/musl/include{pattern}".format(pattern = "/**" if as_glob else ""),
    ]
    return native.glob(paths) if as_glob else paths

def musl_libc_headers(arch, as_glob = False):
    paths = [
        "lib/libc/include/{arch}-linux-musl{pattern}".format(arch = arch, pattern = "/**" if as_glob else ""),  # std.zig.target.osArchName
        "lib/libc/include/generic-musl{pattern}".format(pattern = "/**" if as_glob else ""),
    ]
    return native.glob(paths) if as_glob else paths

def glibc_headers(arch, as_glob = False):
    paths = [
        "lib/libc/include/{arch}-linux-gnu{pattern}".format(arch = arch, pattern = "/**" if as_glob else ""),  # std.zig.target.osArchName
        "lib/libc/include/generic-glibc{pattern}".format(pattern = "/**" if as_glob else ""),
    ]
    return native.glob(paths) if as_glob else paths

def linux_system_headers(os_arch, as_glob = False):
    paths = [
        "lib/libc/include/{os_arch}-linux-any{pattern}".format(os_arch = os_arch, pattern = "/**" if as_glob else ""),  # std.zig.target.osArchName
        "lib/libc/include/any-linux-any{pattern}".format(os_arch = os_arch, pattern = "/**" if as_glob else ""),
    ]
    return native.glob(paths) if as_glob else paths
