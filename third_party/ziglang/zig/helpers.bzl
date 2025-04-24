
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
